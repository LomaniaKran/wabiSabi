import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ВАЖНО: Если запускаешь на Android-эмуляторе, используй 10.0.2.2
  // Если на Edge (браузер), используй localhost
  static const String baseUrl = 'http://localhost:3000/api/auth';

  static Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'email': email, 'password': password}),
    );
    return response.statusCode == 201;
  }

    static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'), // Это вызовет routes/auth.js -> router.post('/login')
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Сервер вернул токен!
    } else {
      return null; // Ошибка
    }
  }
}