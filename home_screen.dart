import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationStatus = "Location permission not granted";

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = "Location services are disabled.";
      });
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationStatus = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = "Location permissions permanently denied.";
      });
      return;
    }

    // Fetch the user's location after permission is granted
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("User Location: ${position.latitude}, ${position.longitude}");

    setState(() {
      _locationStatus = "Location access granted";
    });

    // Navigate to the map screen and pass the user's location correctly
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MapScreen(
            userLocation: position, // ✅ Pass Position instead of LatLng
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Waste Tracker! 🌍",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text("For real-time tracking, we need location access:"),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              child: Text("Allow Location Access"),
            ),
            SizedBox(height: 15),
            Text(
              _locationStatus,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
