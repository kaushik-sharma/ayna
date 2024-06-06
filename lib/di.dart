import 'package:ayna/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:ayna/features/auth/domain/repositories/auth_repository.dart';
import 'package:ayna/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:ayna/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:ayna/features/home/domain/usecases/usecases.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'core/network/custom_dio.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/local/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/home/data/datasources/home_local_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/blocs/home_bloc.dart';

final GetIt sl = GetIt.instance;

void initialize() {
  _injectExternal();
  _injectCore();
  _injectAuth();
  _injectHome();
}

void _injectHome() {
  sl.registerLazySingleton<HomeLocalDatasource>(() => HomeLocalDatasource());

  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(sl<HomeLocalDatasource>()));

  sl.registerLazySingleton<CacheMessageUseCase>(
      () => CacheMessageUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(sl<HomeRepository>()));

  sl.registerLazySingleton<HomeBloc>(
      () => HomeBloc(sl<CacheMessageUseCase>(), sl<GetMessagesUseCase>()));
}

void _injectAuth() {
  sl.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl());
  sl.registerLazySingleton<AuthLocalDatasource>(() => AuthLocalDatasource());

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      sl<AuthDatasource>(),
      sl<AuthLocalDatasource>(),
      sl<HomeLocalDatasource>()));

  sl.registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton<AuthBloc>(() =>
      AuthBloc(sl<SignUpUseCase>(), sl<SignInUseCase>(), sl<SignOutUseCase>()));
}

void _injectCore() {
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(internetConnection: sl<InternetConnection>()));
  sl.registerLazySingleton<GlobalKey<ScaffoldMessengerState>>(
      () => GlobalKey<ScaffoldMessengerState>());
}

void _injectExternal() {
  sl.registerLazySingleton<Dio>(() => CustomDio.instance.dio);
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
}
