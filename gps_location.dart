import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GPSLocation extends StatefulWidget {
  @override
  _GPSLocationState createState() => _GPSLocationState();
}

class _GPSLocationState extends State<GPSLocation> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  double _geofenceRadius = 500.0; // 500 meters
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  final LatLng wasteTruckLocation = LatLng(13.961046, 75.511070); // Truck location

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _getUserLocation();
  }

  /// ✅ Initialize Local Notifications
  void _initNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);
    _notificationsPlugin.initialize(initSettings);
  }

  /// ✅ Get Current Location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ Location permission permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 15),
    );

    _checkGeofence(); // Check geofence when location is updated
  }

  /// ✅ Check if the user is inside the geofence
  void _checkGeofence() {
    if (_currentLocation == null) return;

    double distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      wasteTruckLocation.latitude,
      wasteTruckLocation.longitude,
    );

    if (distance <= _geofenceRadius) {
      print("🚛 Truck is near your location!");
      _showNotification("🚛 Waste Truck Alert", "A truck is near your location.");
    } else {
      print("🚛 Truck is far from your location.");
    }
  }

  /// ✅ Show Local Notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, platformDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geofence Tracker')),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId("currentLocation"),
            position: _currentLocation!,
            infoWindow: InfoWindow(title: "Your Location"),
          ),
          Marker(
            markerId: MarkerId("geofenceLocation"),
            position: wasteTruckLocation,
            infoWindow: InfoWindow(title: "Geofenced Truck"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
          ),
        },
        circles: {
          Circle(
            circleId: CircleId("geofenceRadius"),
            center: wasteTruckLocation,
            radius: _geofenceRadius,
            fillColor: Colors.blue.withOpacity(0.3),
            strokeWidth: 1,
          ),
        },
      ),
    );
  }
}
