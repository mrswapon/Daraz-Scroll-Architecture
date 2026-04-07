import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductsLoadRequested extends ProductEvent {
  const ProductsLoadRequested();
}

class ProductsRefreshRequested extends ProductEvent {
  const ProductsRefreshRequested();
}

class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged({required this.query});
  @override
  List<Object?> get props => [query];
}
