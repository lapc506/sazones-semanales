import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashApiService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey =
      'TU_CLAVE_DE_UNSPLASH'; // ⚠️ cámbiala por tu propia key

  /// Busca fotos en Unsplash
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
