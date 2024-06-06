import 'package:ayna/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, NoParams>> signUp(
      String email, String password, String name);

  Future<Either<Failure, NoParams>> signIn(String email, String password);

  Future<Either<Failure, NoParams>> signOut();
}
