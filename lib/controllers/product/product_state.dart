import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductModel> allProducts;
  final List<ProductModel> electronics;
  final List<ProductModel> jewelery;
  final String searchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.electronics = const [],
    this.jewelery = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  List<ProductModel> _filter(List<ProductModel> products) {
    if (searchQuery.isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  List<ProductModel> get filteredAllProducts => _filter(allProducts);
  List<ProductModel> get filteredElectronics => _filter(electronics);
  List<ProductModel> get filteredJewelery => _filter(jewelery);

  ProductState copyWith({
    ProductStatus? status,
    List<ProductModel>? allProducts,
    List<ProductModel>? electronics,
    List<ProductModel>? jewelery,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      electronics: electronics ?? this.electronics,
      jewelery: jewelery ?? this.jewelery,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allProducts, electronics, jewelery, searchQuery, errorMessage];
}

enum ProductStatus { initial, loading, loaded, error }
