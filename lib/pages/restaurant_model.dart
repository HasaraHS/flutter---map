
class Restaurant {
  final String id;
  final String name;
  final double rating;
  final double lat;
  final double lng;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.lat,
    required this.lng,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['place_id'],
      name: json['name'],
      rating: (json['rating'] as num).toDouble(),
      lat: (json['geometry']['location']['lat'] as num).toDouble(),
      lng: (json['geometry']['location']['lng'] as num).toDouble(),
    );
  }
}
