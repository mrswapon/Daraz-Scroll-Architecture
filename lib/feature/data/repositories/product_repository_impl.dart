import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_dto.dart';
import '../sources/remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final data = await _remoteDataSource.get('/products');
      final productDtos = (data as List)
          .map((json) => ProductDto.fromJson(json).toEntity())
          .toList();
      return Either.right(productDtos);
    } on RemoteDataSourceException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(
      String category) async {
    try {
      final data =
          await _remoteDataSource.get('/products/category/$category');
      final productDtos = (data as List)
          .map((json) => ProductDto.fromJson(json).toEntity())
          .toList();
      return Either.right(productDtos);
    } on RemoteDataSourceException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final data = await _remoteDataSource.get('/products/categories');
      final categories = (data as List).cast<String>();
      return Either.right(categories);
    } on RemoteDataSourceException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
