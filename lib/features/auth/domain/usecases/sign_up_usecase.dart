import 'package:ayna/core/usecases/usecase.dart';
import 'package:ayna/features/auth/domain/entities/sign_up_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<NoParams, SignUpEntity> {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(SignUpEntity entity) async {
    return await repository.signUp(entity.email, entity.password, entity.name);
  }
}
