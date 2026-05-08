import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/add_combo_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/update_cart_selection_usecase.dart';
import '../../domain/usecases/auto_update_cart_selection_usecase.dart';
import '../controllers/cart_controller.dart';
import '../controllers/add_to_cart_controller.dart';
import '../controllers/add_combo_to_cart_controller.dart';
import '../state/add_combo_to_cart_state.dart';

/// Provider for Dio instance for cart API with token refresh interceptor
final cartDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add safe auth interceptor (pass-through only, no refresh logic)
  dio.interceptors.add(TokenRefreshInterceptor(ref));

  // Add logging interceptor with enhanced lifecycle tracking
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[DIO] REQUEST → ${options.method} ${options.path}');
        if (options.data != null) {
          debugPrint('[DIO] Request Body: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '[DIO] RESPONSE → ${response.requestOptions.path} (${response.statusCode})',
        );
        debugPrint('[DIO] Response received, calling handler.next()');
        handler.next(response);
        debugPrint(
          '[DIO] handler.next() completed for ${response.requestOptions.path}',
        );
      },
      onError: (error, handler) {
        debugPrint('[DIO] ERROR → ${error.requestOptions.path}');
        debugPrint('[DIO] Error: ${error.message}');
        if (error.response != null) {
          debugPrint('[DIO] Error Status: ${error.response?.statusCode}');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Provider for cart remote data source
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  final dio = ref.read(cartDioProvider);
  return CartRemoteDataSourceImpl(dio: dio);
});

/// Provider for cart repository
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dataSource = ref.read(cartRemoteDataSourceProvider);
  return CartRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for use cases
final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return AddToCartUseCase(repository);
});

final getCartUseCaseProvider = Provider<GetCartUseCase>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return GetCartUseCase(repository);
});

final removeCartItemUseCaseProvider = Provider<RemoveCartItemUseCase>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return RemoveCartItemUseCase(repository);
});
final updateCartSelectionUseCaseProvider = Provider<UpdateCartSelectionUseCase>(
  (ref) {
    final repository = ref.read(cartRepositoryProvider);
    return UpdateCartSelectionUseCase(repository);
  },
);

final autoUpdateCartSelectionUseCaseProvider =
    Provider<AutoUpdateCartSelectionUseCase>((ref) {
      final repository = ref.read(cartRepositoryProvider);
      return AutoUpdateCartSelectionUseCase(repository);
    });

final addComboToCartUseCaseProvider = Provider<AddComboToCartUseCase>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return AddComboToCartUseCase(repository);
});

/// Provider for cart controller
final cartControllerProvider =
    StateNotifierProvider<CartController, CartPageState>((ref) {
      return CartController(
        getCartUseCase: ref.read(getCartUseCaseProvider),
        removeCartItemUseCase: ref.read(removeCartItemUseCaseProvider),
        updateCartSelectionUseCase: ref.read(
          updateCartSelectionUseCaseProvider,
        ),
        autoUpdateCartSelectionUseCase: ref.read(
          autoUpdateCartSelectionUseCaseProvider,
        ),
      );
    });

/// Provider family for add to cart button (per productID)
final addToCartButtonProvider =
    StateNotifierProvider.family<
      AddToCartController,
      AddToCartButtonState,
      String
    >((ref, productID) {
      return AddToCartController(
        productID: productID,
        addToCartUseCase: ref.read(addToCartUseCaseProvider),
        ref: ref,
      );
    });

/// Provider family for combo add to cart button (per comboID)
final addComboToCartButtonProvider = StateNotifierProvider.autoDispose
    .family<AddComboToCartController, AddComboToCartState, String>((
      ref,
      comboID,
    ) {
      return AddComboToCartController(
        comboID: comboID,
        addComboToCartUseCase: ref.read(addComboToCartUseCaseProvider),
        ref: ref,
      );
    });
