

import '../models/halal_status.dart';

class HalalAnalyzer {
  static final List<String> haramKeywords = [
    'pork', 'ham', 'bacon', 'lard', 'gelatin', 'alcohol', 'ethanol',
    'carmine', 'e120', 'e904', 'e441', 'rennet', 'non-halal', 'blood'
  ];

  static final List<String> mashboohKeywords = [
    'emulsifier', 'e471', 'e472', 'monoglyceride', 'diglyceride',
    'enzyme', 'natural flavour'
  ];

  static HalalStatus analyzeIngredients(String ingredients) {
    if (ingredients.isEmpty) return HalalStatus.unknown;
    final lower = ingredients.toLowerCase();
    for (var kw in haramKeywords) {
      if (lower.contains(kw)) return HalalStatus.haram;
    }
    for (var kw in mashboohKeywords) {
      if (lower.contains(kw)) return HalalStatus.mashbooh;
    }
    return HalalStatus.halal;
  }
}