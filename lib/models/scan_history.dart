class ScanHistory {
  final int? id;
  final String barcode;
  final String productName;
  final String halalStatus;
  final String ingredients;
  final DateTime scannedAt;

  ScanHistory({
    this.id,
    required this.barcode,
    required this.productName,
    required this.halalStatus,
    required this.ingredients,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'productName': productName,
      'halalStatus': halalStatus,
      'ingredients': ingredients,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'],
      barcode: map['barcode'],
      productName: map['productName'],
      halalStatus: map['halalStatus'],
      ingredients: map['ingredients'],
      scannedAt: DateTime.parse(map['scannedAt']),
    );
  }
}