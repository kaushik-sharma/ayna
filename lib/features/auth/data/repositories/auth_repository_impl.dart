import 'dart:developer';

import 'package:ayna/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:ayna/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/data/datasources/home_local_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource remoteDatasource;
  final AuthLocalDatasource authLocalDatasource;
  final HomeLocalDatasource homeLocalDatasource;

  AuthRepositoryImpl(this.remoteDatasource, this.authLocalDatasource,
      this.homeLocalDatasource);

  @override
  Future<Either<Failure, NoParams>> signUp(
      String email, String password, String name) async {
    try {
      final authToken = await remoteDatasource.signUp(email, password, name);
      authLocalDatasource.saveAuthToken(authToken);
      return const Right(NoParams());
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      log(e.toString());
      return Left(Failure(e.message ?? 'Authentication failed.'));
    } catch (e) {
      log(e.toString());
      return const Left(Failure('Authentication failed.'));
    }
  }

  @override
  Future<Either<Failure, NoParams>> signIn(
      String email, String password) async {
    try {
      final authToken = await remoteDatasource.signIn(email, password);
      authLocalDatasource.saveAuthToken(authToken);
      return const Right(NoParams());
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      log(e.toString());
      return Left(Failure(e.message ?? 'Authentication failed.'));
    } catch (e) {
      log(e.toString());
      return const Left(Failure('Authentication failed.'));
    }
  }

  @override
  Future<Either<Failure, NoParams>> signOut() async {
    try {
      await remoteDatasource.signOut();
      authLocalDatasource.clear();
      homeLocalDatasource.clear();
      return const Right(NoParams());
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      log(e.toString());
      return const Left(Failure());
    } catch (e) {
      log(e.toString());
      return const Left(Failure());
    }
  }
}
