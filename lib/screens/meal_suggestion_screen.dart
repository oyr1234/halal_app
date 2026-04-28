import 'package:flutter/material.dart';
import '../models/meal_suggestion.dart';
import '../services/meal_suggestion_service.dart';
import '../widgets/meal_card.dart';

class MealSuggestionScreen extends StatefulWidget {
  const MealSuggestionScreen({super.key});

  @override
  State<MealSuggestionScreen> createState() => _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends State<MealSuggestionScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ingredientInputController = TextEditingController(); // ← new

  final List<String> _ingredients = [];
  List<MealSuggestion> _suggestions = [];
  bool _isLoading = false;
  String _error = '';
  final List<String> _selectedRestrictions = [];

  final List<String> _restrictionOptions = [
    'gluten-free', 'dairy-free', 'nut-free', 'vegan', 'low-spice'
  ];

  // ─── Add ingredient from text field ───
  void _addIngredient() {
    final value = _ingredientInputController.text.trim();
    if (value.isEmpty) return;
    if (_ingredients.contains(value.toLowerCase())) {
      _ingredientInputController.clear();
      return;
    }
    setState(() {
      _ingredients.add(value.toLowerCase());
      _ingredientInputController.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() => _ingredients.remove(ingredient));
  }

  // ─── Fetch suggestions ───
  Future<void> _getSuggestions() async {
    if (_locationController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your location');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _suggestions = [];
    });

    try {
      final results = await MealSuggestionService.getSuggestions(
        location: _locationController.text.trim(),
        ingredients: List<String>.from(_ingredients),
        dietaryRestrictions: _selectedRestrictions,
      );
      setState(() => _suggestions = results);
    } catch (e) {
      setState(() => _error = 'Could not load suggestions. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _ingredientInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Meal Suggestions'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Meal Planner',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Powered by Ollama (open source)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location input
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Your Location',
                hintText: 'e.g. Tokyo, Japan',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Ingredients input ───
            Text('Available Ingredients', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientInputController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addIngredient(),
                    decoration: InputDecoration(
                      labelText: 'Add ingredient',
                      hintText: 'e.g. chicken, rice, tomatoes…',
                      prefixIcon: const Icon(Icons.add_shopping_cart),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _addIngredient,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            // Ingredient chips
            if (_ingredients.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _ingredients.map((ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeIngredient(ingredient),
                    backgroundColor:
                    colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                        color: colorScheme.onSecondaryContainer),
                  );
                }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'No ingredients added — AI will suggest meals based on your location.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.outline),
              ),
            ],

            const SizedBox(height: 16),

            // Dietary restrictions
            Text('Dietary Restrictions', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _restrictionOptions.map((r) {
                final selected = _selectedRestrictions.contains(r);
                return FilterChip(
                  label: Text(r),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      val
                          ? _selectedRestrictions.add(r)
                          : _selectedRestrictions.remove(r);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Error message
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error,
                    style: TextStyle(color: colorScheme.error)),
              ),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _getSuggestions,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading
                    ? 'Getting suggestions...'
                    : 'Get Meal Ideas'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results
            if (_suggestions.isNotEmpty) ...[
              Text(
                'Suggested Meals',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._suggestions.map((meal) => MealCard(meal: meal)),
            ],
          ],
        ),
      ),
    );
  }
}