// lib/data/repositories/post_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/data/auth_storage.dart';
import 'package:wabisabi_front/data/models/post.dart';

// --- Базовый URL для API ---
// Убедись, что он совпадает с тем, что настроено на сервере
// Если на сервере используется '/api/posts', то baseUrl должен быть '/api'
// А сам эндпоинт будет '/api/posts'
const String _baseUrl = 'http://localhost:3000/api'; // Пример, может отличаться

// --- ПРОВАЙДЕР РЕПОЗИТОРИЯ ПОСТОВ ---
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

class PostRepository {
  
  // --- ПОЛУЧЕНИЕ ВСЕХ ПОСТОВ ---
  Future<List<Post>> fetchPosts() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Не аутентифицирован');

    final response = await http.get(
      Uri.parse('$_baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> postsJson = jsonDecode(response.body);
      // Преобразуем каждый JSON в объект Post
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Сессия истекла'); // Перехватываем ошибку сессии
    } else {
      throw Exception('Не удалось загрузить посты: ${response.statusCode} ${response.body}');
    }
  }

  // --- ПОЛУЧЕНИЕ ОДНОГО ПОСТА ПО ID ---
  Future<Post> fetchPostById(String postId) async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Не аутентифицирован');

    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$postId'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> postJson = jsonDecode(response.body);
      return Post.fromJson(postJson);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Сессия истекла');
    } else {
      throw Exception('Не удалось загрузить пост $postId: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Post>> fetchPostsByAuthor(String authorId) async {
    final allPosts = await fetchPosts();
    return allPosts.where((post) => post.authorId == authorId).toList();
  }

  // --- СОЗДАНИЕ НОВОГО ПОСТА ---
  Future<Post> createPost(Post post) async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Не аутентифицирован');

    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Отправляем данные поста в формате JSON
      body: jsonEncode(post.toJson()), 
    );

    if (response.statusCode == 201) { // 201 Created
      final Map<String, dynamic> createdPostJson = jsonDecode(response.body);
      return Post.fromJson(createdPostJson);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Сессия истекла');
    } else {
      throw Exception('Не удалось создать пост: ${response.statusCode} ${response.body}');
    }
  }
}