import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class MlKitService {
  final barcodeScanner = BarcodeScanner();
  final textRecognizer = TextRecognizer();

  Future<String?> scanBarcode(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final barcodes = await barcodeScanner.processImage(inputImage);
    if (barcodes.isNotEmpty) {
      return barcodes.first.rawValue;
    }
    return null;
  }

  Future<String?> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text.trim();
  }

  void dispose() {
    barcodeScanner.close();
    textRecognizer.close();
  }
}