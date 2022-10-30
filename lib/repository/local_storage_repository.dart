import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepo {
  void setToken(String token) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString('x-auth-token');
  }
}
