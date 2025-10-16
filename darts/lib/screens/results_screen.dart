import 'package:flutter/material.dart';
import '../services/api_service.dart'; // ✅ используем API вместо DbService

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final data = await ApiService.getResults(); // 🔄 запрос через API
      setState(() {
        results = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка загрузки результатов: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Результаты"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadResults),
        ],
      ),
      body: results.isEmpty
          ? const Center(child: Text("Нет результатов"))
          : ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final r = results[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(r["name"] ?? "Без имени"),
            trailing: Text("Очки: ${r["score"] ?? 0}"),
            subtitle: r["created_at"] != null
                ? Text("Дата: ${r["created_at"]}")
                : null,
          );
        },
      ),
    );
  }
}
