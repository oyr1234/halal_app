import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'; // ✅ fixed
import '../services/ml_kit_service.dart';
import '../services/open_food_facts_service.dart';
import '../services/halal_analyzer.dart';
import '../services/database_helper.dart';
import '../models/scan_history.dart';
import '../models/halal_status.dart';
import 'result_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  CameraController? _controller;
  final MlKitService _mlKit = MlKitService();
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _scanBarcode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isProcessing = true);
    try {
      final XFile picture = await _controller!.takePicture();
      final File image = File(picture.path);
      final barcode = await _mlKit.scanBarcode(image);
      if (barcode == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No barcode found')));
        setState(() => _isProcessing = false);
        return;
      }
      final product = await _offService.getProductByBarcode(barcode);
      String productName = product?['product_name'] ?? 'Unknown product';
      String ingredients = product?['ingredients_text'] ?? '';
      if (ingredients.isEmpty && product != null) {
        ingredients = product?['ingredients']?.toString() ?? '';
      }
      final status = HalalAnalyzer.analyzeIngredients(ingredients);
      final scan = ScanHistory(
        barcode: barcode,
        productName: productName,
        halalStatus: status.label,
        ingredients: ingredients,
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
  void dispose() {
    _controller?.dispose();
    _mlKit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Scan Barcode')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _scanBarcode,
              icon: Icon(Icons.camera),
              label: Text(_isProcessing ? 'Processing...' : 'Capture & Scan'),
            ),
          ),
        ],
      ),
    );
  }
}