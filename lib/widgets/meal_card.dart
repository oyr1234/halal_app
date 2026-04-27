import 'package:flutter/material.dart';
import '../models/meal_suggestion.dart';

class MealCard extends StatelessWidget {
  final MealSuggestion meal;
  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Text(meal.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        meal.cuisineType,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(meal.preparationTime,
                      style: theme.textTheme.labelSmall),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(meal.description, style: theme.textTheme.bodyMedium),

            const SizedBox(height: 10),

            // Ingredients chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: meal.ingredients.map((i) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(i, style: theme.textTheme.labelSmall),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Halal notes
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      meal.halalNotes,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}