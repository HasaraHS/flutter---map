// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map/pages/restaurant_servie.dart';
import 'pages/restaurant_model.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final List<Marker> _markers = [];
  late RestaurantService _restaurantService;

  @override
  void initState() {
    super.initState();
    _restaurantService = RestaurantService(apiKey: 'YOUR_API_KEY');
    _fetchAndDisplayRestaurants();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchAndDisplayRestaurants() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Restaurant> restaurants = await _restaurantService.fetchRestaurants('pizza', position.latitude, position.longitude);

    setState(() {
      _markers.clear();
      for (final restaurant in restaurants) {
        _markers.add(Marker(
          markerId: MarkerId(restaurant.id),
          position: LatLng(restaurant.lat, restaurant.lng),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: restaurant.rating.toString(),
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Example'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: Set<Marker>.of(_markers),
      ),
    );
  }
}
