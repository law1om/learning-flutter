import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final api = ApiService();
  List<Recipe> recipes = [];

  Future<void> loadRecipes() async {
    recipes = await api.getRecipes();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Все рецепты')),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, i) {
          final r = recipes[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(r.title),
              subtitle: Text(r.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(r.favorite ? Icons.favorite : Icons.favorite_border),
                    onPressed: () async {
                      await api.toggleFavorite(r.id, !r.favorite);
                      loadRecipes();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await api.deleteRecipe(r.id);
                      loadRecipes();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
