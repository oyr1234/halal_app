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
    required String preferences,
    required List<String> dietaryRestrictions,
    String madhab = 'general',
  }) async {
    try {
      return await _getOllamaSuggestions(
        location: location,
        preferences: preferences,
        dietaryRestrictions: dietaryRestrictions,
        madhab: madhab,
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
    required String preferences,
    required List<String> dietaryRestrictions,
    required String madhab,
  }) async {
    final prompt = _buildPrompt(
      location,
      preferences,
      dietaryRestrictions,
      madhab,
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

    return list
        .map((e) => MealSuggestion.fromJson(e))
        .toList();
  }

  // ─────────────────────────────
  // PROMPT (FIXED)
  // ─────────────────────────────
  static String _buildPrompt(
      String location,
      String preferences,
      List<String> restrictions,
      String madhab,
      ) {
    return '''
Return ONLY valid JSON array.

Generate 4 halal meals in $location.

Preferences: $preferences
Restrictions: ${restrictions.join(', ')}

Each meal MUST include:
name, description, ingredients, cuisineType,
preparationTime, halalNotes, emoji, recipeSteps

IMPORTANT:
- recipeSteps MUST be an array of strings
- each step must start with action verb
- NO text outside JSON

Format:
[
  {
    "name": "Example",
    "description": "...",
    "ingredients": ["..."],
    "cuisineType": "...",
    "preparationTime": "...",
    "halalNotes": "...",
    "emoji": "🍛",
    "recipeSteps": [
      "Step 1",
      "Step 2"
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
  // FALLBACK (FIXED)
  // ─────────────────────────────
  static List<MealSuggestion> _getLocalSuggestions() {
    return [
      MealSuggestion(
        name: 'Grilled Chicken Plate',
        description: 'Simple halal chicken with rice and salad.',
        ingredients: ['chicken', 'rice', 'salad'],
        cuisineType: 'International',
        preparationTime: '20 min',
        halalNotes: 'Ensure halal-certified chicken.',
        emoji: '🍗',

        // 🔥 IMPORTANT FIX
        recipeSteps: [
          'Season chicken with spices',
          'Grill until fully cooked',
          'Cook rice with salt',
          'Prepare fresh salad',
          'Serve together on plate',
        ],
      ),
    ];
  }
}