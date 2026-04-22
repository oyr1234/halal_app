import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/ custom_button.dart';
import 'barcode_scanner_screen.dart';
import 'ocr_scanner_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Halal Scanner'), actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Scan Barcode',
              icon: Icons.qr_code_scanner,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BarcodeScannerScreen()),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Scan Ingredients (OCR)',
              icon: Icons.text_snippet,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OcrScannerScreen()),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'History',
              icon: Icons.history,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'About',
              icon: Icons.info,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}