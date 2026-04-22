import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import '../models/scan_history.dart';
import '../models/halal_status.dart';
import '../services/settings_service.dart';

class ResultScreen extends StatelessWidget {
  final ScanHistory scan;

  const ResultScreen({required this.scan});

  void _playSoundAndVibrate(BuildContext context) {
    final settings = Provider.of<SettingsService>(context, listen: false);
    if (settings.soundEnabled) {
      AudioPlayer().play(AssetSource('sounds/scan_beep.wav'));
    }
    if (settings.vibrationEnabled) {
      Vibration.vibrate(duration: 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    _playSoundAndVibrate(context);
    HalalStatus status = scan.halalStatus.contains('Halal') ? HalalStatus.halal :
    scan.halalStatus.contains('Haram') ? HalalStatus.haram :
    scan.halalStatus.contains('Mashbooh') ? HalalStatus.mashbooh : HalalStatus.unknown;

    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${scan.productName}', style: TextStyle(fontSize: 22)),
            SizedBox(height: 10),
            Text('Barcode: ${scan.barcode}'),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              color: status.color.withOpacity(0.2),
              child: Text('Status: ${scan.halalStatus}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: status.color)),
            ),
            SizedBox(height: 20),
            Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: SingleChildScrollView(child: Text(scan.ingredients.isEmpty ? 'No ingredients listed' : scan.ingredients))),
          ],
        ),
      ),
    );
  }
}