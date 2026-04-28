import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../widgets/custom_button.dart';
import 'barcode_scanner_screen.dart';
import 'ocr_scanner_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 🔥 function مشتركة للصوت + vibration
  Future<void> handleFeedback(BuildContext context) async {
    final settings = Provider.of<SettingsService>(context, listen: false);

    // 🔊 sound (محمي)
    try {
      await SoundService.playClick(settings.soundEnabled);
    } catch (e) {
      debugPrint("Sound error: $e");
    }

    // 📳 vibration (محمي)
    try {
      if (settings.vibrationEnabled) {
        final hasVibrator = await Vibration.hasVibrator() ?? false;
        if (hasVibrator) {
          Vibration.vibrate(duration: 100);
        }
      }
    } catch (e) {
      debugPrint("Vibration error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halal Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await handleFeedback(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Scan Barcode',
              icon: Icons.qr_code_scanner,
              onPressed: () async {
                await handleFeedback(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BarcodeScannerScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Scan Ingredients (OCR)',
              icon: Icons.text_snippet,
              onPressed: () async {
                await handleFeedback(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OcrScannerScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'History',
              icon: Icons.history,
              onPressed: () async {
                await handleFeedback(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'About',
              icon: Icons.info,
              onPressed: () async {
                await handleFeedback(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}