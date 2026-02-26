import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<ProductModel>> getAllProducts() async {
    final data = await _apiService.get('/products');
    return (data as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final data = await _apiService.get('/products/category/$category');
    return (data as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<String>> getCategories() async {
    final data = await _apiService.get('/products/categories');
    return (data as List).cast<String>();
  }
}
