import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // форс-инициализация базы, чтобы увидеть ошибки сразу
    await DatabaseHelper.instance.database;
    print('>>> DB initialized OK');
  } catch (e, st) {
    print('!!! DB init error: $e\n$st');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskApp(),
    );
  }
}

// -------------------- Модель --------------------
class Task {
  final int? id;
  final String title;
  final String description;

  Task({this.id, required this.title, required this.description});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map["id"] as int?,
      title: map["title"] as String? ?? '',
      description: map["description"] as String? ?? '',
    );
  }
}

// -------------------- База данных --------------------
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("tasks.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    print('>>> DB path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('>>> Creating tasks table...');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT
          )
        ''');
        print('>>> tasks table created');
      },
    );
  }

  Future<int> insertTask(Task task) async {
    try {
      final db = await instance.database;
      final id = await db.insert("tasks", task.toMap());
      print('>>> insertTask id=$id title=${task.title}');
      return id;
    } catch (e, st) {
      print('!!! insertTask error: $e\n$st');
      rethrow;
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final db = await instance.database;
      final maps = await db.query("tasks", orderBy: "id DESC");
      print('>>> getTasks found=${maps.length}');
      return maps.map((m) => Task.fromMap(m)).toList();
    } catch (e, st) {
      print('!!! getTasks error: $e\n$st');
      rethrow;
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      final db = await instance.database;
      final res = await db.update(
        "tasks",
        task.toMap(),
        where: "id = ?",
        whereArgs: [task.id],
      );
      print('>>> updateTask id=${task.id} res=$res');
      return res;
    } catch (e, st) {
      print('!!! updateTask error: $e\n$st');
      rethrow;
    }
  }

  Future<int> deleteTask(int id) async {
    try {
      final db = await instance.database;
      final res = await db.delete("tasks", where: "id = ?", whereArgs: [id]);
      print('>>> deleteTask id=$id res=$res');
      return res;
    } catch (e, st) {
      print('!!! deleteTask error: $e\n$st');
      rethrow;
    }
  }
}

// -------------------- UI --------------------
class TaskApp extends StatefulWidget {
  const TaskApp({super.key});

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  List<Task> tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getTasks();
      setState(() {
        tasks = data;
      });
    } catch (e) {
      _showError('Ошибка получения задач: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    print('!!! UI error: $msg');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showForm({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? "");
    final descController = TextEditingController(text: task?.description ?? "");

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(task == null ? "Новая задача" : "Редактировать задачу"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Название"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Описание"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty) {
                  _showError('Название не может быть пустым');
                  return;
                }
                try {
                  if (task == null) {
                    await DatabaseHelper.instance.insertTask(
                      Task(title: title, description: desc),
                    );
                  } else {
                    await DatabaseHelper.instance.updateTask(
                      Task(id: task.id, title: title, description: desc),
                    );
                  }
                  await _refreshTasks();
                  Navigator.of(ctx).pop();
                } catch (e) {
                  _showError('Ошибка сохранения: $e');
                }
              },
              child: Text(task == null ? "Добавить" : "Сохранить"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(int id) async {
    try {
      await DatabaseHelper.instance.deleteTask(id);
      await _refreshTasks();
    } catch (e) {
      _showError('Ошибка удаления: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Задачи (SQLite)"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text("Нет задач"))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (ctx, index) {
          final t = tasks[index];
          return Dismissible(
            key: ValueKey(t.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteTask(t.id!),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(t.title),
              subtitle: Text(t.description),
              onTap: () => _showForm(task: t),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showForm(task: t),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
