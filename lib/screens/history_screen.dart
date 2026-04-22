import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/scan_history.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistory> _scans = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final scans = await DatabaseHelper.instance.getAllScans();
    setState(() => _scans = scans);
  }

  Future<void> _clearHistory() async {
    await DatabaseHelper.instance.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
        actions: [
          IconButton(icon: Icon(Icons.delete), onPressed: _clearHistory),
        ],
      ),
      body: _scans.isEmpty
          ? Center(child: Text('No scans yet'))
          : ListView.builder(
        itemCount: _scans.length,
        itemBuilder: (ctx, i) {
          final scan = _scans[i];
          return ListTile(
            title: Text(scan.productName),
            subtitle: Text('${scan.halalStatus} - ${scan.scannedAt.toLocal()}'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(scan: scan))),
          );
        },
      ),
    );
  }
}