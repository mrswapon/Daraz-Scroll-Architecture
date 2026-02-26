import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

//==================> Load products for all tabs. <=================
class ProductsLoadRequested extends ProductEvent {
  const ProductsLoadRequested();
}

//====================> Refresh products (pull-to-refresh). Reloads all tab data. <=====================
class ProductsRefreshRequested extends ProductEvent {
  const ProductsRefreshRequested();
}

//=====================> Search/filter products by name (client-side). <===========================
class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged({required this.query});
  @override
  List<Object?> get props => [query];
}
