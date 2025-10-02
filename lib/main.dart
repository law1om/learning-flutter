import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/recipes_page.dart';
import 'pages/favourites_page.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    RecipesPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Каталог рецептов',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Рецепты'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
          ],
        ),
      ),
    );
  }
}
