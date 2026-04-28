import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_suggestion.dart';

class MealSuggestionService {
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';
  static const String _model = 'llama3.2:latest';

  // ─────────────────────────────
  // PUBLIC METHOD
  // ─────────────────────────────
  static Future<List<MealSuggestion>> getSuggestions({
    required String location,
    required List<String> ingredients,
    required List<String> dietaryRestrictions,
  }) async {
    try {
      return await _getOllamaSuggestions(
        location: location,
        ingredients: ingredients,
        dietaryRestrictions: dietaryRestrictions,
      );
    } catch (e) {
      print('Ollama failed: $e');
      return _getLocalSuggestions();
    }
  }

  // ─────────────────────────────
  // OLLAMA CALL
  // ─────────────────────────────
  static Future<List<MealSuggestion>> _getOllamaSuggestions({
    required String location,
    required List<String> ingredients,
    required List<String> dietaryRestrictions,
  }) async {
    final prompt = _buildPrompt(
      location,
      ingredients,
      dietaryRestrictions,
    );

    final response = await http.post(
      Uri.parse(_ollamaUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': _model,
        'prompt': prompt,
        'stream': false,
        'format': 'json',
      }),
    );

    final body = jsonDecode(response.body);
    final raw = (body['response'] ?? '').toString();

    if (raw.isEmpty) {
      throw Exception("Empty response");
    }

    return _parseMeals(raw);
  }

  // ─────────────────────────────
  // PARSER (ROBUST)
  // ─────────────────────────────
  static List<MealSuggestion> _parseMeals(String raw) {
    final cleaned = _repairJson(raw);
    List<dynamic> list = [];

    try {
      final decoded = jsonDecode(cleaned);

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        list = decoded['meals'] ?? [decoded];
      }
    } catch (_) {
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');

      if (start != -1 && end != -1) {
        list = jsonDecode(cleaned.substring(start, end + 1));
      }
    }

    return list.map((e) => MealSuggestion.fromJson(e)).toList();
  }

  // ─────────────────────────────
  // PROMPT
  // ─────────────────────────────
  static String _buildPrompt(
      String location,
      List<String> ingredients,
      List<String> restrictions,
      ) {
    final ingredientList = ingredients.isNotEmpty
        ? ingredients.join(', ')
        : 'common pantry staples';

    final restrictionText = restrictions.isNotEmpty
        ? restrictions.join(', ')
        : 'none';

    return '''
Return ONLY a valid JSON array. No text before or after. No markdown.

You are a chef. Suggest 4 meals that can be made using these available ingredients:
[$ingredientList]

Location/cuisine context: $location
Dietary restrictions: $restrictionText

Rules:
- Meals do NOT have to be exclusively halal, but MUST include a halalNotes field explaining any halal considerations or substitutions (e.g. use halal-certified meat, omit alcohol, etc.)
- Use as many of the provided ingredients as possible
- You may add common pantry items (salt, oil, water, spices) if needed
- Each meal must have detailed step-by-step preparation instructions

Each object MUST have exactly these fields:
- name: string
- description: string (1–2 sentences)
- ingredients: array of strings (only what is actually used)
- cuisineType: string
- preparationTime: string (e.g. "30 min")
- halalNotes: string (halal guidance or "No special halal concerns for this dish")
- emoji: single emoji string
- recipeSteps: array of strings — MINIMUM 5 steps, each starting with an action verb, detailed enough to actually cook the meal

Example format:
[
  {
    "name": "Tomato Egg Stir-fry",
    "description": "A quick and comforting Chinese home-style dish.",
    "ingredients": ["eggs", "tomatoes", "garlic", "salt", "oil"],
    "cuisineType": "Chinese",
    "preparationTime": "15 min",
    "halalNotes": "All ingredients are halal. No concerns.",
    "emoji": "🍳",
    "recipeSteps": [
      "Crack 3 eggs into a bowl, add a pinch of salt, and beat well.",
      "Dice 2 tomatoes into medium chunks and mince 2 garlic cloves.",
      "Heat oil in a wok over high heat until shimmering.",
      "Pour in eggs and scramble until just set, then remove from pan.",
      "Add garlic to the same pan and stir-fry for 30 seconds until fragrant.",
      "Add tomatoes and cook for 2 minutes until they release their juices.",
      "Return eggs to the pan, season with salt, toss together and serve hot."
    ]
  }
]
''';
  }

  // ─────────────────────────────
  // JSON CLEANER
  // ─────────────────────────────
  static String _repairJson(String json) {
    return json
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .replaceAll('\n', ' ')
        .trim();
  }

  // ─────────────────────────────
  // FALLBACK
  // ─────────────────────────────
  static List<MealSuggestion> _getLocalSuggestions() {
    return [
      MealSuggestion(
        name: 'Garlic Fried Rice',
        description: 'A simple and satisfying fried rice using pantry staples.',
        ingredients: ['rice', 'garlic', 'eggs', 'soy sauce', 'oil'],
        cuisineType: 'Asian',
        preparationTime: '20 min',
        halalNotes: 'All ingredients are halal. Ensure soy sauce has no alcohol additives.',
        emoji: '🍚',
        recipeSteps: [
          'Cook rice and let it cool completely (or use day-old rice).',
          'Mince 4 garlic cloves finely.',
          'Heat oil in a large pan or wok over high heat.',
          'Add garlic and stir-fry for 30 seconds until golden and fragrant.',
          'Push garlic to the side, crack in eggs, and scramble until just cooked.',
          'Add cold rice and break up any clumps, tossing everything together.',
          'Drizzle soy sauce over the rice, stir-fry for 2 more minutes.',
          'Taste, adjust seasoning, and serve immediately.',
        ],
      ),
    ];
  }
}