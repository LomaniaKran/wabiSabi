import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_storage.dart'; // Убедись, что ты создала этот файл!

class UserRepository {
  // !!! ВАЖНО: Если работаешь в эмуляторе Android, замени localhost на 10.0.2.2 !!!
  final String baseUrl = 'http://localhost:3000/api'; 

  // 1. Метод Входа (Login)
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': identifier, // Ключ должен быть 'identifier'
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка входа: ${response.body}');
    }
  }

  // 2. Метод Регистрации (Register)
  Future<Map<String, dynamic>> register(String username, String email, String password, String bio) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "username": username,
        "email": email,
        "password": password,
        "bio": bio
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
      final token = await AuthStorage.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/profile'), // Путь к нашему API
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

    if (response.statusCode != 200) {
      throw Exception('Ошибка при сохранении: ${response.statusCode}');
    }
  }

  Future<List<String>> fetchAvailableSkills() async {
    final token = await AuthStorage.getToken();
    // Проверь baseUrl!
    final response = await http.get(
      Uri.parse('$baseUrl/profile/skills'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> skillsJson = jsonDecode(response.body);
      return skillsJson.map((item) => item.toString()).toList();
    } else {
      throw Exception('Не удалось получить список навыков: ${response.statusCode}');
    }
  }

  // 3. Метод получения профиля (защищенный)
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final token = await AuthStorage.getToken();
    
    if (token == null) {
      throw Exception('Токен не найден. Выполните вход.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Отправляем токен
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Если 401, нужно вызвать AuthNotifier.logout()
      throw Exception('Ошибка получения профиля: ${response.statusCode}');
    }
  }
}