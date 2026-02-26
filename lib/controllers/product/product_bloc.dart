import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const ProductState()) {
    on<ProductsLoadRequested>(_onLoadRequested);
    on<ProductsRefreshRequested>(_onRefreshRequested);
    on<ProductSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    await _fetchAllProducts(emit);
  }

  Future<void> _onRefreshRequested(
    ProductsRefreshRequested event,
    Emitter<ProductState> emit,
  ) async {
    await _fetchAllProducts(emit);
  }

  void _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _fetchAllProducts(Emitter<ProductState> emit) async {
    try {
      //=====================> Fetch all three tab datasets in parallel. <=========================
      final results = await Future.wait([
        _productRepository.getAllProducts(),
        _productRepository.getProductsByCategory('electronics'),
        _productRepository.getProductsByCategory('jewelery'),
      ]);

      emit(state.copyWith(
        status: ProductStatus.loaded,
        allProducts: results[0],
        electronics: results[1],
        jewelery: results[2],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
