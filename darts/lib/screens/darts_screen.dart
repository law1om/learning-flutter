import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart'; // ✅ правильный импорт

class DartsPainter extends CustomPainter {
  final double? hitX;
  final double? hitY;

  DartsPainter({this.hitX, this.hitY});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    paint.color = Colors.black;
    canvas.drawCircle(center, 100, paint);

    paint.color = Colors.blue;
    canvas.drawCircle(center, 50, paint);

    paint.color = Colors.red;
    canvas.drawCircle(center, 10, paint);

    if (hitX != null && hitY != null) {
      paint.color = Colors.green;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center.translate(hitX!, hitY!), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DartsScreen extends StatefulWidget {
  const DartsScreen({super.key});

  @override
  State<DartsScreen> createState() => _DartsScreenState();
}

class _DartsScreenState extends State<DartsScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _throws = 0;
  int _score = 0;
  double? _lastX;
  double? _lastY;
  String? _playerName;

  void _throwDart() {
    if (_playerName == null || _playerName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Введите имя игрока!")),
      );
      return;
    }

    if (_throws < 3) {
      setState(() {
        _throws++;
        final rand = Random();
        final x = rand.nextDouble() * 20 - 10;
        final y = rand.nextDouble() * 20 - 10;

        final distance = sqrt(x * x + y * y);
        int points = 0;
        if (distance <= 1) {
          points = 10;
        } else if (distance <= 5) {
          points = 5;
        } else if (distance <= 10) {
          points = 1;
        }

        _score += points;
        _lastX = x * 10;
        _lastY = y * 10;
      });
    }
  }

  void _saveResult() async {
    if (_playerName == null || _playerName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Введите имя игрока перед сохранением!")),
      );
      return;
    }

    try {
      await ApiService.saveResult(_playerName!, _score); // ✅ вместо DbService
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Результат сохранён!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка сохранения: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetGame() {
    setState(() {
      _throws = 0;
      _score = 0;
      _lastX = null;
      _lastY = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Дартс")),
      body: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: DartsPainter(hitX: _lastX, hitY: _lastY),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Имя игрока"),
              onChanged: (val) => _playerName = val,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _throws < 3 ? _throwDart : null,
                        child: Text(
                          _throws < 3 ? "Бросить дротик" : "Игра окончена",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _score > 0 ? _saveResult : null,
                        child: const Text("Сохранить"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text("Новая игра"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text("Бросков: $_throws / 3"),
          Text("Очки: $_score"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
