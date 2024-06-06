import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDatasource {
  Future<String> signUp(String email, String password, String name);

  Future<String> signIn(String email, String password);

  Future<void> signOut();
}

class AuthDatasourceImpl extends AuthDatasource {
  @override
  Future<String> signUp(String email, String password, String name) async {
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await userCredential.user!.updateDisplayName(name);

    return (await userCredential.user!.getIdToken())!;
  }

  @override
  Future<String> signIn(String email, String password) async {
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return (await userCredential.user!.getIdToken())!;
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
