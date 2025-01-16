import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _addMarker(widget.location, 'Hospital', Icons.location_on);
  }

  // Add marker to the map at the given location
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

  // Add polyline to the map to connect two locations
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

  // Get the directions from Google Maps API
  // Get the directions from Google Maps API
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyB-86UTgKSTmSjppYQccJKIbHLjXfc-Q0o';  // Replace with your API key
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Directions response: $data');  // Debugging the response

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



  // Handle tap on the map
  void _onTap(LatLng location) {
    setState(() {
      tappedLocation = location;
    });

    // Add a marker for the tapped location
    _addMarker(location, 'Tapped Location', Icons.pin_drop);

    // Get directions and draw the route on the map
    _getDirections(widget.location, location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        initialCameraPosition: CameraPosition(
          target: widget.location,
          zoom: 15,
        ),
        markers: _markers,
        polylines: _polylines,
        onTap: _onTap, // Handle map taps
      ),
    );
  }
}
