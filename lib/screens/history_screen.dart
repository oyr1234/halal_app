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
    setState(() {
      _scans = scans;
    });
  }

  Future<void> _deleteScan(int id) async {
    await DatabaseHelper.instance.deleteScan(id);
    _loadHistory();
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear History'),
        content: Text(
          'Delete all scan history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearHistory();
      _loadHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All history deleted')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'halal':
        return Colors.green;
      case 'haram':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _clearHistory,
          ),
        ],
      ),

      body: _scans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No scans yet',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _scans.length,
        itemBuilder: (ctx, i) {
          final scan = _scans[i];

          return Dismissible(
            key: Key(scan.id.toString()),
            direction: DismissDirection.endToStart,

            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),

            confirmDismiss: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete Scan'),
                  content: Text(
                      'Are you sure you want to delete this scan?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(ctx, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(ctx, true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              return confirm ?? false;
            },

            onDismissed: (_) async {
              await DatabaseHelper.instance
                  .deleteScan(scan.id!);

              setState(() {
                _scans.removeAt(i);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text('${scan.productName} deleted'),
                ),
              );
            },

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                _statusColor(scan.halalStatus),
                child: Icon(Icons.qr_code,
                    color: Colors.white, size: 18),
              ),

              title: Text(
                scan.productName,
                style:
                TextStyle(fontWeight: FontWeight.w600),
              ),

              subtitle: Text(
                '${scan.halalStatus} · ${_formatDate(scan.scannedAt)}',
                style: TextStyle(
                  color: _statusColor(scan.halalStatus),
                  fontSize: 12,
                ),
              ),

              // ✅ DELETE BUTTON ADDED HERE
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      final confirm =
                      await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete Scan'),
                          content: Text(
                              'Delete ${scan.productName}?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, true),
                              child: Text('Delete',
                                  style: TextStyle(
                                      color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await DatabaseHelper.instance
                            .deleteScan(scan.id!);

                        setState(() {
                          _scans.removeAt(i);
                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                                'Deleted successfully'),
                          ),
                        );
                      }
                    },
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResultScreen(scan: scan),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}