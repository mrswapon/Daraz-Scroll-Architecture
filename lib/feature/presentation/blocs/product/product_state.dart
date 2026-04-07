import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

class ProductState extends Equatable {
  final List<Product> allProducts;
  final List<Product> electronics;
  final List<Product> jewelery;
  final String searchQuery;

  const ProductState({
    this.allProducts = const [],
    this.electronics = const [],
    this.jewelery = const [],
    this.searchQuery = '',
  });

  List<Product> _filter(List<Product> products) {
    if (searchQuery.isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  List<Product> get filteredAllProducts => _filter(allProducts);
  List<Product> get filteredElectronics => _filter(electronics);
  List<Product> get filteredJewelery => _filter(jewelery);

  ProductState copyWith({
    List<Product>? allProducts,
    List<Product>? electronics,
    List<Product>? jewelery,
    String? searchQuery,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      electronics: electronics ?? this.electronics,
      jewelery: jewelery ?? this.jewelery,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allProducts, electronics, jewelery, searchQuery];
}
