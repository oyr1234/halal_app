import 'package:flutter/material.dart';

enum HalalStatus { halal, haram, mashbooh, unknown }

extension HalalStatusExtension on HalalStatus {
  String get label {
    switch (this) {
      case HalalStatus.halal:
        return 'Halal ✅';
      case HalalStatus.haram:
        return 'Haram ❌';
      case HalalStatus.mashbooh:
        return 'Mashbooh ⚠️';
      case HalalStatus.unknown:
        return 'Unknown ❓';
    }
  }

  Color get color {
    switch (this) {
      case HalalStatus.halal:
        return Colors.green;
      case HalalStatus.haram:
        return Colors.red;
      case HalalStatus.mashbooh:
        return Colors.orange;
      case HalalStatus.unknown:
        return Colors.grey;
    }
  }
}