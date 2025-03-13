import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator

class MapScreen extends StatefulWidget {
  final Position userLocation;

  MapScreen({required this.userLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  late LatLng _userLocation;
  LatLng _truckLocation = LatLng(13.960178, 75.510884); // Your mobile's location (acting as the truck)

  @override
  void initState() {
    super.initState();
    _userLocation = LatLng(widget.userLocation.latitude, widget.userLocation.longitude); // ✅ Convert Position to LatLng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Waste Tracker Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _userLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId("user"),
            position: _userLocation,
            infoWindow: InfoWindow(title: "Your Location (Laptop)"),
          ),
          Marker(
            markerId: MarkerId("truck"),
            position: _truckLocation,
            infoWindow: InfoWindow(title: "Truck Location (Your Mobile)"),
          ),
        },
        circles: {
          Circle(
            circleId: CircleId("geofence"),
            center: _userLocation,
            radius: 500, // Geofence radius in meters
            strokeColor: Colors.blue,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.3),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
