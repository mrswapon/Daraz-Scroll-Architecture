import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../repositories/product_repository.dart';

class GetCategoriesUseCase extends UseCase<List<String>, NoParams> {
  final ProductRepository _productRepository;

  GetCategoriesUseCase({required ProductRepository productRepository})
      : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await _productRepository.getCategories();
  }
}
