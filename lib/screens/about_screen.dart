import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Halal Scanner', style: TextStyle(fontSize: 28)),
            SizedBox(height: 10),
            Text('Uses Firebase ML Kit: Barcode Scanner, Text Recognition, Language Identification'),
            SizedBox(height: 20),
            Text('Data provided by Open Food Facts API'),
            SizedBox(height: 10),
            Text('Halal status determined by local ingredient analysis'),
          ],
        ),
      ),
    );
  }
}