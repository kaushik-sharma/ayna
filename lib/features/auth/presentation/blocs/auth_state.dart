part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.modeChanged(AuthMode mode) = _ModeChanged;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.loaded() = _Loaded;

  const factory AuthState.authSuccess() = _AuthSuccess;

  const factory AuthState.authFailure(String message) = _AuthFailure;

  const factory AuthState.signOutSuccess() = _SignOutSuccess;

  const factory AuthState.signOutFailure() = _SignOutFailure;
}
