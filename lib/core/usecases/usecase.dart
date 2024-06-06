import 'package:dartz/dartz.dart';

import '../failures/failure.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

class NoParams {
  const NoParams();
}
