import 'package:flutter/material.dart';
import 'darts_screen.dart';
import 'results_screen.dart';   // ✅ импорт экрана с результатами
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Дартс")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DartsScreen()),
                );
              },
              child: const Text("Играть"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResultsScreen()),
                );
              },
              child: const Text("Результаты"),
            ),
          ],
        ),
      ),
    );
  }
}
