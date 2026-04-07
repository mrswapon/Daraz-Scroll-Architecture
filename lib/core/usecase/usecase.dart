import 'package:equatable/equatable.dart';
import '../error/failure.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  
  @override
  List<Object?> get props => [];
}

class Either<L, R> {
  final L? _left;
  final R? _right;
  
  const Either.left(this._left) : _right = null;
  const Either.right(this._right) : _left = null;
  
  bool get isLeft => _left != null;
  bool get isRight => _right != null;
  
  L get left => _left!;
  R get right => _right!;
  
  T fold<T>(T Function(L) leftFn, T Function(R) rightFn) {
    if (_left != null) {
      return leftFn(_left as L);
    }
    return rightFn(_right as R);
  }
}
