part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.toggleMode(AuthMode mode) = _ToggleMode;

  const factory AuthEvent.signUp(SignUpEntity entity) = _SignUp;

  const factory AuthEvent.signIn(SignInEntity entity) = _SignIn;

  const factory AuthEvent.signOut() = _SignOut;
}
