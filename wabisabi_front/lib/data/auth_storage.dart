import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyToken = 'jwt_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    print("AuthStorage: Token saved to SharedPreferences.");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    print("AuthStorage: getToken result: $token");
    return token;
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    print("AuthStorage: Token deleted.");
  }
}