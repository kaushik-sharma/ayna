import 'package:ayna/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<NoParams, NoParams> {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(NoParams params) async {
    return await repository.signOut();
  }
}
