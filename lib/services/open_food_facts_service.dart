import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$baseUrl$barcode.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return data['product'];
        }
      }
    } catch (e) {
      print('Error fetching product: $e');
    }
    return null;
  }
}