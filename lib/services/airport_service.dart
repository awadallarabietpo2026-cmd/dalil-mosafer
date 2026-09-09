import 'dart:convert';
import 'package:http/http.dart' as http;

class AirportSuggestion {
  final String code;
  final String cityName;
  final String countryName;

  AirportSuggestion({
    required this.code,
    required this.cityName,
    required this.countryName,
  });

  String get displayName =>
      countryName.isNotEmpty ? '$cityName - $countryName' : cityName;
}

class AirportService {
  static Future<List<AirportSuggestion>> search(String term) async {
    if (term.trim().length < 2) return [];

    final uri = Uri.parse(
      'https://autocomplete.travelpayouts.com/places2'
      '?term=${Uri.encodeComponent(term)}&locale=ar&types[]=city&types[]=airport',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final List<dynamic> data = jsonDecode(response.body);
      return data
          .where((item) => item['code'] != null && item['code'] != '')
          .map<AirportSuggestion>((item) => AirportSuggestion(
                code: item['code'],
                cityName: item['city_name'] ?? item['name'] ?? '',
                countryName: item['country_name'] ?? '',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
