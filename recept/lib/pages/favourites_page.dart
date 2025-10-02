import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final api = ApiService();
  List<Recipe> favorites = [];

  Future<void> loadFavorites() async {
    favorites = await api.getFavorites();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, i) {
          final r = favorites[i];
          return ListTile(
            title: Text(r.title),
            subtitle: Text(r.description),
          );
        },
      ),
    );
  }
}
