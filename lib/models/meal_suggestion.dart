class MealSuggestion {
  final String name;
  final String description;
  final List<String> ingredients;
  final String cuisineType;
  final String preparationTime;
  final String halalNotes;
  final String emoji;

  // 🔥 ADD THIS
  final List<String> recipeSteps;

  MealSuggestion({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.cuisineType,
    required this.preparationTime,
    required this.halalNotes,
    required this.emoji,
    required this.recipeSteps,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      cuisineType: json['cuisineType'] ?? '',
      preparationTime: json['preparationTime'] ?? '',
      halalNotes: json['halalNotes'] ?? '',
      emoji: json['emoji'] ?? '🍽️',

      // 🔥 SAFE FALLBACK FOR ALL POSSIBLE KEYS
      recipeSteps: List<String>.from(
        json['recipeSteps'] ??
            json['recipe_steps'] ??
            json['steps'] ??
            [],
      ),
    );
  }
}