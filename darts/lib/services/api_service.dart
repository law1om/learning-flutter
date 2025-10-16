import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.201.3.48:3000"; // ⚠️ IP твоего бэкенда

  // Получение результатов
  static Future<List<Map<String, dynamic>>> getResults() async {
    final url = Uri.parse("$baseUrl/results");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Ошибка загрузки: ${response.body}");
    }
  }

  // Сохранение результата
  static Future<void> saveResult(String name, int score) async {
    final url = Uri.parse("$baseUrl/results");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "score": score}),
    );

    if (response.statusCode != 200) {
      throw Exception("Ошибка сохранения: ${response.body}");
    }
  }
}
