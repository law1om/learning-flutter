class Recipe {
  final int id;
  final String title;
  final String description;
  final bool favorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.favorite,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      favorite: map['favorite'] ?? false,
    );
  }
}
