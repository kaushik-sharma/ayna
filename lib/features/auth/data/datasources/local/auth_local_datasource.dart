import 'package:hive_flutter/hive_flutter.dart';

class AuthLocalDatasource {
  final _box = Hive.box<String>('auth_box');

  void saveAuthToken(String authToken) {
    _box.put('auth_token', authToken);
  }

  bool isAuthenticated() {
    return _box.get('auth_token') != null;
  }

  void clear() {
    _box.clear();
  }
}
