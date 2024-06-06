import 'package:ayna/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/sign_in_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase implements UseCase<NoParams, SignInEntity> {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(SignInEntity entity) async {
    return await repository.signIn(entity.email, entity.password);
  }
}
