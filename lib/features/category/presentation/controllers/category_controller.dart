import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';

/// Category page state
class CategoryState {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  CategoryState copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Category controller managing category page state
class CategoryController extends StateNotifier<CategoryState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  bool _hasFetched = false;

  CategoryController(this.getAllCategoriesUseCase) : super(const CategoryState());

  /// Load categories (only once unless forced)
  Future<void> loadCategories({bool force = false}) async {
    // Don't refetch if already loaded unless forced
    if (_hasFetched && !force) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final categories = await getAllCategoriesUseCase();
      _hasFetched = true;
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh categories (pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final categories = await getAllCategoriesUseCase();
      _hasFetched = true;
      state = state.copyWith(
        categories: categories,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }
}
