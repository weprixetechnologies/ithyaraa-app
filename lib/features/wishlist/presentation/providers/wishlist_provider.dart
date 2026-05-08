import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shop/domain/entities/product.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/usecases/wishlist_usecases.dart';
import '../../domain/entities/wishlist.dart';
import '../states/wishlist_state.dart';

// --- Dependency Injection ---

/// Provider for Authenticated Dio instance for Wishlist API
final wishlistDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Auth & Logging Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Inject Auth Token
        final authState = ref.read(authProvider);
        if (authState.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${authState.accessToken}';
        }

        debugPrint(
          '[Wishlist DIO] REQUEST → ${options.method} ${options.path}',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[Wishlist DIO] RESPONSE → ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
          '[Wishlist DIO] ERROR → ${error.message} : ${error.response?.data}',
        );
        handler.next(error);
      },
    ),
  );

  return dio;
});

final wishlistRemoteDataSourceProvider = Provider<WishlistRemoteDataSource>((
  ref,
) {
  return WishlistRemoteDataSourceImpl(dio: ref.read(wishlistDioProvider));
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(
    remoteDataSource: ref.read(wishlistRemoteDataSourceProvider),
  );
});

final getWishlistUseCaseProvider = Provider<GetWishlistUseCase>((ref) {
  return GetWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final addWishlistUseCaseProvider = Provider<AddWishlistUseCase>((ref) {
  return AddWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final removeWishlistUseCaseProvider = Provider<RemoveWishlistUseCase>((ref) {
  return RemoveWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final removeProductFromWishlistUseCaseProvider =
    Provider<RemoveProductFromWishlistUseCase>((ref) {
      return RemoveProductFromWishlistUseCase(
        ref.read(wishlistRepositoryProvider),
      );
    });

// --- StateNotifier ---

class WishlistNotifier extends StateNotifier<WishlistState> {
  final GetWishlistUseCase _getWishlistUseCase;
  final AddWishlistUseCase _addWishlistUseCase;
  final RemoveProductFromWishlistUseCase _removeProductFromWishlistUseCase;

  // Debounce timer to prevent rapid clicks
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  WishlistNotifier({
    required GetWishlistUseCase getWishlistUseCase,
    required AddWishlistUseCase addWishlistUseCase,
    required RemoveProductFromWishlistUseCase removeProductFromWishlistUseCase,
  }) : _getWishlistUseCase = getWishlistUseCase,
       _addWishlistUseCase = addWishlistUseCase,
       _removeProductFromWishlistUseCase = removeProductFromWishlistUseCase,
       super(const WishlistState());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Loads the wishlist from API.
  /// Respects `isWishlistHydrated` to prevent redundant calls.
  Future<void> loadWishlist({bool forceRefresh = false}) async {
    // CRITICAL: Hydration Check
    if (state.isWishlistHydrated && !forceRefresh) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final wishlist = await _getWishlistUseCase();
      state = state.copyWith(
        items: wishlist.items,
        isLoading: false,
        isWishlistHydrated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Optimistically adds or removes a product from the wishlist.
  /// requires [productEntity] for optimistic ADD to work correctly.
  /// Debounced to prevent rapid clicks (300ms delay).
  Future<void> toggleWishlist(
    String productID, {
    ProductEntity? productEntity,
  }) async {
    // Cancel any pending debounced operation
    _debounceTimer?.cancel();

    // Debounce: wait for the delay before executing
    final completer = Completer<void>();
    _debounceTimer = Timer(_debounceDelay, () async {
      try {
        await _performToggle(productID, productEntity: productEntity);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Internal method that performs the actual toggle operation.
  Future<void> _performToggle(
    String productID, {
    ProductEntity? productEntity,
  }) async {
    final exists = state.containsProduct(productID);
    final previousItems = List<WishlistItemEntity>.from(state.items);

    if (exists) {
      // --- Optimistic REMOVE ---
      final updatedItems = state.items
          .where((item) => item.product.productID != productID)
          .toList();
      state = state.copyWith(items: updatedItems);

      try {
        await _removeProductFromWishlistUseCase(productID);
        // Success: State is consistent.
      } catch (e) {
        // Rollback
        state = state.copyWith(
          items: previousItems,
          error: "Failed to remove from wishlist",
        );
      }
    } else {
      // --- Optimistic ADD ---
      if (productEntity != null) {
        // Generate a temp ID for the optimistic item
        final newItem = WishlistItemEntity(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          product: productEntity,
        );
        state = state.copyWith(items: [...state.items, newItem]);
      } else {
        // If productEntity is missing, we can't show it optimistically in the list properly.
        // We skip optimistic update for list, but maybe we should still try calling API.
        // Or we could add a placeholder? No, strictly Clean Architecture.
        // We just proceed to API call. The user might see a delay if they go to Wishlist page immediately.
        // But the icon on product page will likely listen to `contains(id)` which works if we add check.
        // Wait, `containsProduct` checks `items`. If we don't add to items, it returns false.
        // So for the icon to toggle, we MUST add something to items.
        // Ideally, callers MUST pass productEntity.
      }

      try {
        final result = await _addWishlistUseCase(productID);
        // Server returns the updated wishlist (or added item).
        // Our UseCase returns WishlistEntity (the full list from RepositoryImpl).
        state = state.copyWith(items: result.items);
      } catch (e) {
        // Rollback
        state = state.copyWith(
          items: previousItems,
          error: "Failed to add to wishlist",
        );
      }
    }
  }

  /// Resets state (e.g. on logout)
  void reset() {
    state = const WishlistState();
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>(
  (ref) {
    return WishlistNotifier(
      getWishlistUseCase: ref.read(getWishlistUseCaseProvider),
      addWishlistUseCase: ref.read(addWishlistUseCaseProvider),
      removeProductFromWishlistUseCase: ref.read(
        removeProductFromWishlistUseCaseProvider,
      ),
    );
  },
);
