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
  final TextEditingController _preferencesController = TextEditingController();

  List<MealSuggestion> _suggestions = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedMadhab = 'general';
  final List<String> _selectedRestrictions = [];

  final List<String> _madhabs = [
    'general', 'hanafi', 'shafii', 'maliki', 'hanbali'
  ];
  final List<String> _restrictionOptions = [
    'gluten-free', 'dairy-free', 'nut-free', 'vegan', 'low-spice'
  ];

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
        preferences: _preferencesController.text.trim(),
        dietaryRestrictions: _selectedRestrictions,
        madhab: _selectedMadhab,
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
    _preferencesController.dispose();
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
                            'Halal Meal AI',
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

            const SizedBox(height: 12),

            // Preferences input
            TextField(
              controller: _preferencesController,
              decoration: InputDecoration(
                labelText: 'Food Preferences (optional)',
                hintText: 'e.g. spicy food, rice dishes, street food',
                prefixIcon: const Icon(Icons.restaurant),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            // Madhab selector
            Text('School of Thought', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _madhabs.map((m) {
                final selected = _selectedMadhab == m;
                return ChoiceChip(
                  label: Text(m[0].toUpperCase() + m.substring(1)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedMadhab = m),
                );
              }).toList(),
            ),

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
                    : 'Get Halal Meal Ideas'),
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