import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../api/api.dart';

class ApiService {
  final String baseUrl = apiUrl;

  Future<List<Recipe>> getRecipes() async {
    final res = await http.get(Uri.parse('$baseUrl/recipes'));
    final data = jsonDecode(res.body);
    return (data as List).map((r) => Recipe.fromMap(r)).toList();
  }

  Future<void> addRecipe(String title, String description) async {
    await http.post(
      Uri.parse('$baseUrl/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );
  }

  Future<void> deleteRecipe(int id) async {
    await http.delete(Uri.parse('$baseUrl/recipes/$id'));
  }

  Future<void> toggleFavorite(int id, bool favorite) async {
    await http.patch(
      Uri.parse('$baseUrl/recipes/$id/favorite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'favorite': favorite}),
    );
  }

  Future<List<Recipe>> getFavorites() async {
    final res = await http.get(Uri.parse('$baseUrl/favorites'));
    final data = jsonDecode(res.body);
    return (data as List).map((r) => Recipe.fromMap(r)).toList();
  }
}
