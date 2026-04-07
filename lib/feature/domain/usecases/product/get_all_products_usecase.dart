import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class GetAllProductsUseCase extends UseCase<List<Product>, NoParams> {
  final ProductRepository _productRepository;

  GetAllProductsUseCase({required ProductRepository productRepository})
      : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await _productRepository.getAllProducts();
  }
}
