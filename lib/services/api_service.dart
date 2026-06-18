import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  Future<String?> traducirTexto({
    required String texto,
    required String source,
    required String target,
  }) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];

    final url = Uri.parse(
      "https://translation.googleapis.com/language/translate/v2?key=$apiKey",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "q": texto,
          "source": source,
          "target": target,
          "format": "text",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"]["translations"][0]["translatedText"];
      } else {
        print("Error API: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Error conexión: $e");
      return null;
    }
  }

  Future<String?> detectarIdioma({required String texto}) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];

    final url = Uri.parse(
      "https://translation.googleapis.com/language/detect/v2?key=$apiKey",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"q": texto}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"]["detections"][0][0]["language"];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
