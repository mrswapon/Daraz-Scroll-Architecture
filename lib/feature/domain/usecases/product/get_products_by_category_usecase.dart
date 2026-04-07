import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class GetProductsByCategoryParams extends Equatable {
  final String category;

  const GetProductsByCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}

class GetProductsByCategoryUseCase
    extends UseCase<List<Product>, GetProductsByCategoryParams> {
  final ProductRepository _productRepository;

  GetProductsByCategoryUseCase({required ProductRepository productRepository})
      : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<Product>>> call(
      GetProductsByCategoryParams params) async {
    return await _productRepository.getProductsByCategory(params.category);
  }
}
