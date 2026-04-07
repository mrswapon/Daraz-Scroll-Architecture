import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/product/get_all_products_usecase.dart';
import '../../../domain/usecases/product/get_products_by_category_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetProductsByCategoryUseCase _getElectronicsUseCase;
  final GetProductsByCategoryUseCase _getJeweleryUseCase;

  ProductBloc({
    required GetAllProductsUseCase getAllProductsUseCase,
    required GetProductsByCategoryUseCase getElectronicsUseCase,
    required GetProductsByCategoryUseCase getJeweleryUseCase,
  })  : _getAllProductsUseCase = getAllProductsUseCase,
        _getElectronicsUseCase = getElectronicsUseCase,
        _getJeweleryUseCase = getJeweleryUseCase,
        super(const ProductState()) {
    on<ProductsLoadRequested>(_onLoadRequested);
    on<ProductsRefreshRequested>(_onRefreshRequested);
    on<ProductSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
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
      final allProductsResult = await _getAllProductsUseCase(const NoParams());
      final electronicsResult = await _getElectronicsUseCase(
        const GetProductsByCategoryParams(category: 'electronics'),
      );
      final jeweleryResult = await _getJeweleryUseCase(
        const GetProductsByCategoryParams(category: 'jewelery'),
      );

      // If any failed, emit empty state
      if (allProductsResult.isLeft || electronicsResult.isLeft || jeweleryResult.isLeft) {
        emit(const ProductState());
        return;
      }

      emit(ProductState(
        allProducts: allProductsResult.right,
        electronics: electronicsResult.right,
        jewelery: jeweleryResult.right,
      ));
    } catch (e) {
      emit(const ProductState());
    }
  }
}
