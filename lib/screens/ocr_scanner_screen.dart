import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/ml_kit_service.dart';
import '../services/halal_analyzer.dart';
import '../services/database_helper.dart';
import '../models/scan_history.dart';
import '../models/halal_status.dart';
import 'result_screen.dart';

class OcrScannerScreen extends StatefulWidget {
  @override
  _OcrScannerScreenState createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  final MlKitService _mlKit = MlKitService();
  bool _isProcessing = false;

  Future<void> _pickAndScan() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() => _isProcessing = true);
    try {
      final text = await _mlKit.recognizeText(File(picked.path));
      if (text == null || text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No text recognized')));
        setState(() => _isProcessing = false);
        return;
      }
      final status = HalalAnalyzer.analyzeIngredients(text);
      final scan = ScanHistory(
        barcode: 'OCR',
        productName: 'Scanned Ingredients',
        halalStatus: status.label,
        ingredients: text,
        scannedAt: DateTime.now(),
      );
      await DatabaseHelper.instance.insertScan(scan);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(scan: scan)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR Ingredient Scanner')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : _pickAndScan,
          icon: Icon(Icons.camera_alt),
          label: Text(_isProcessing ? 'Scanning...' : 'Take a photo of ingredients'),
        ),
      ),
    );
  }
}