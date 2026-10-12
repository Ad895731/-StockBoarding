import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }



  static Future<void> createProduct({
  required String name,
  String? brand,
  String? category,
  double? mrp,
  String? quantity,
  double? sellingPrice,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/products/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'brand': brand,
      'category': category,
      'mrp': mrp,
      'quantity': quantity,
      'selling_price': sellingPrice,
    }),
  );

  if (response.statusCode != 200 ){
    throw Exception('Failed to create product');
  }
}


  static Future<String> uploadImage(XFile image, {List<int>? bytes}) async {
    final uri = Uri.parse('$baseUrl/products/upload-image');
    final request = http.MultipartRequest('POST', uri);

    final fileBytes = bytes ?? await image.readAsBytes();
    final filename = image.name.isNotEmpty ? image.name : 'product_image.jpg';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['path'] ?? data['filename'] ?? 'uploaded';
    } else {
      throw Exception('Server returned ${response.statusCode}: ${response.body}');
    }
  }
}