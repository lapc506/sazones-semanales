import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UnsplashApiService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static String get _accessKey => dotenv.env['UNSPLASH_KEY']!;

  static Future<List<String>> searchPhotos(String query, {int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/search/photos?page=$page&query=$query');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Client-ID $_accessKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      // Devuelve solo las URLs pequeñas de cada imagen
      return results.map((photo) => photo['urls']['small'] as String).toList();
    } else {
      throw Exception('Error al buscar fotos: ${response.statusCode}');
    }
  }
}
