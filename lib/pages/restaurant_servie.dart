
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'restaurant_model.dart';

Future<List<Restaurant>> fetchRestaurants(String preference, double lat, double lng) async {
  final response = await http.get(
    Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&type=restaurant&keyword=$preference&key=YOUR_API_KEY')
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final results = json['results'] as List;
    return results.map((place) => Restaurant.fromJson(place)).toList();
  } else {
    throw Exception('Failed to load restaurants');
  }
}
