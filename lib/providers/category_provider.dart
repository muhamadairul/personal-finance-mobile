import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/category.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Category> get expenseCategories =>
      categories.where((c) => c.isExpense).toList();
  List<Category> get incomeCategories =>
      categories.where((c) => c.isIncome).toList();
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final ApiService _apiService = ApiService();

  CategoryNotifier() : super(const CategoryState());

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiConfig.categories);
      final List data = response.data['data'];
      final categories = data.map((json) => Category.fromJson(json)).toList();
      state = CategoryState(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat kategori');
    }
  }

  Future<bool> addCategory(Category category) async {
    print(category.toJson());
    try {
      final response = await _apiService.post(
        ApiConfig.categories,
        data: category.toJson(),
      );
      final newCategory = Category.fromJson(response.data['data']);
      state = state.copyWith(categories: [...state.categories, newCategory]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.categories}/${category.id}',
        data: category.toJson(),
      );
      final updated = Category.fromJson(response.data['data']);
      state = state.copyWith(
        categories: state.categories
            .map((c) => c.id == updated.id ? updated : c)
            .toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _apiService.delete('${ApiConfig.categories}/$id');
      state = state.copyWith(
        categories: state.categories.where((c) => c.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    return CategoryNotifier();
  },
);
