import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For platform detection
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // For web view

class MapScreen extends StatefulWidget {
  final String address;
  final LatLng location;

  const MapScreen({
    Key? key,
    required this.address,
    required this.location,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? tappedLocation;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Add a marker for the initial location (mobile only)
      _addMarker(widget.location, 'Hospital', Icons.location_on);
    }
  }

  // Add marker to the map at the given location (mobile only)
  void _addMarker(LatLng position, String title, IconData icon) {
    final markerId = MarkerId(position.toString());

    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  // Add polyline to the map to connect two locations (mobile only)
  void _addPolyline(List<LatLng> points) {
    final polylineId = PolylineId('route');

    final polyline = Polyline(
      polylineId: polylineId,
      points: points,
      color: Colors.red,
      width: 5,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  // Get the directions from Google Maps API (mobile only)
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyDE8Np1v3GFvTH51cQvaRyWtJf8v226Keo'; // Replace with your API key
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin
        .latitude},${origin.longitude}&destination=${destination
        .latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Directions response: $data'); // Debugging the response

        final routes = data['routes'];
        if (routes.isNotEmpty) {
          final route = routes[0];
          final polylinePoints = route['legs'][0]['steps']
              .map<LatLng>((step) {
            final lat = step['end_location']['lat'];
            final lng = step['end_location']['lng'];
            return LatLng(lat, lng);
          }).toList();

          if (polylinePoints.isNotEmpty) {
            _addPolyline(polylinePoints);
          } else {
            print("No polyline points available");
          }
        } else {
          print("No routes found in the Directions API response.");
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("Error fetching directions: $error");
    }
  }

  // Handle tap on the map (mobile only)
  void _onTap(LatLng location) {
    setState(() {
      tappedLocation = location;
    });

    // Add a marker for the tapped location
    _addMarker(location, 'Tapped Location', Icons.pin_drop);

    // Get directions and draw the route on the map
    _getDirections(widget.location, location);
  }

  // Build the map for web using InAppWebView
  Widget _buildWebMap() {
    final iframeHtml = """
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body, html, #map {
            height: 100%;
            margin: 0;
            padding: 0;
          }
        </style>
        <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDE8Np1v3GFvTH51cQvaRyWtJf8v226Keo&callback=initMap&libraries=places&v=weekly" async></script>
        <script>
          function initMap() {
            const initialLocation = { lat: ${widget.location.latitude}, lng: ${widget.location.longitude} };
            const map = new google.maps.Map(document.getElementById("map"), {
              center: initialLocation,
              zoom: 12,
            });

            const marker = new google.maps.Marker({
              position: initialLocation,
              map: map,
              title: "Location",
            });
          }
        </script>
      </head>
      <body>
        <div id="map"></div>
      </body>
    </html>
  """;

    return InAppWebView(
      initialData: InAppWebViewInitialData(data: iframeHtml),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          transparentBackground: true,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: kIsWeb
          ? _buildWebMap() // Use InAppWebView for web
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        initialCameraPosition: CameraPosition(
          target: widget.location,
          zoom: 15,
        ),
        markers: _markers,
        polylines: _polylines,
        onTap: _onTap, // Handle map taps (mobile only)
      ),
    );
  }
}