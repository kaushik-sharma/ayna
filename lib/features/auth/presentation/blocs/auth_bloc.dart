import 'package:ayna/core/usecases/usecase.dart';
import 'package:ayna/features/auth/domain/entities/sign_up_entity.dart';
import 'package:ayna/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/sign_in_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

enum AuthMode { signUp, signIn }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc(this.signUpUseCase, this.signInUseCase, this.signOutUseCase)
      : super(const AuthState.initial()) {
    on<_ToggleMode>((event, emit) {
      emit(_ModeChanged(event.mode));
    });
    on<_SignUp>((event, emit) async {
      emit(const _Loading());
      final result = await signUpUseCase(event.entity);
      emit(const _Loaded());
      result.fold<void>(
        (left) => emit(_AuthFailure(left.message!)),
        (right) => emit(const _AuthSuccess()),
      );
    });
    on<_SignIn>((event, emit) async {
      emit(const _Loading());
      final result = await signInUseCase(event.entity);
      emit(const _Loaded());
      result.fold<void>(
        (left) => emit(_AuthFailure(left.message!)),
        (right) => emit(const _AuthSuccess()),
      );
    });
    on<_SignOut>((event, emit) async {
      final result = await signOutUseCase(const NoParams());
      result.fold<void>(
        (left) => emit(const _SignOutFailure()),
        (right) => emit(const _SignOutSuccess()),
      );
    });
  }
}
