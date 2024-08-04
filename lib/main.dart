import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'pages/restaurant_model.dart';
import 'pages/restaurant_servie.dart'; 

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
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    _startPositionStream();
  }

  void _startPositionStream() {
    positionStream = Geolocator.getPositionStream().listen(
      (Position position) {
        print('${position.latitude}, ${position.longitude}');
        _updateCameraPosition(position);
      },
    );
  }

  void _updateCameraPosition(Position position) {
    final newCameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15.0,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  @override
  void dispose() {
    positionStream.cancel();
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fetchAndDisplayRestaurants();
  }

  Future<void> _fetchAndDisplayRestaurants() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Restaurant> restaurants = await fetchRestaurants('pizza', position.latitude, position.longitude);

    setState(() {
      _markers.clear();
      for (final restaurant in restaurants) {
        final markerId = MarkerId(restaurant.id);
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          restaurant.lat,
          restaurant.lng,
        );
        _markers.add(Marker(
          markerId: markerId,
          position: LatLng(restaurant.lat, restaurant.lng),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: 'Rating: ${restaurant.rating}\nDistance: ${distanceInMeters.toStringAsFixed(2)} meters',
          ),
          onTap: () => _onMarkerTapped(markerId),
        ));
      }
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    final marker = _markers.firstWhere((m) => m.markerId == markerId);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(marker.infoWindow.title ?? ''),
                subtitle: Text(marker.infoWindow.snippet ?? ''),
              ),
              // Add more details here, such as reviews, contact number, etc.
            ],
          ),
        );
      },
    );
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
