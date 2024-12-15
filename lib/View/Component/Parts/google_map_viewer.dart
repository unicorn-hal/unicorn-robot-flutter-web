import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';

import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class GoogleMapViewer extends StatefulWidget {
  const GoogleMapViewer({
    super.key,
    required this.point,
    this.destination,
  });
  final LatLng point;
  final LatLng? destination;

  @override
  State<GoogleMapViewer> createState() => _GoogleMapViewerState();
}

class _GoogleMapViewerState extends State<GoogleMapViewer> {
  GoogleMapController? mapController;

  late LatLng _point;
  late LatLng? _destination;

  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _point = widget.point;
    _destination = widget.destination;

    if (_destination != null) {
      _fetchRoute();
    }
  }

  @override
  void didUpdateWidget(GoogleMapViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.point != oldWidget.point ||
        widget.destination != oldWidget.destination) {
      setState(() {
        _point = widget.point;
        _destination = widget.destination;
        _polylines.clear();
      });
      if (_destination != null) {
        _fetchRoute();
        _animateCameraToBounds();
      } else {
        try {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(_point),
          );
        } catch (e) {
          Log.echo('Error: $e');
        }
      }
    }
  }

  Future<void> _fetchRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();
    try {
      String apiKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_point.latitude},${_point.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$apiKey'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load directions');
      }

      final data = json.decode(response.body);

      if (data['routes'].isEmpty) {
        throw Exception('No routes found');
      }

      final encodedPolyline = data['routes'][0]['overview_polyline']['points'];

      List<LatLng> points = polylinePoints
          .decodePolyline(encodedPolyline)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    } catch (e) {
      Log.echo('Error fetching route: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_destination != null) {
      _animateCameraToBounds();
    } else {
      controller.animateCamera(
        CameraUpdate.newLatLng(_point),
      );
    }
  }

  void _animateCameraToBounds() {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _point.latitude < _destination!.latitude
            ? _point.latitude
            : _destination!.latitude,
        _point.longitude < _destination!.longitude
            ? _point.longitude
            : _destination!.longitude,
      ),
      northeast: LatLng(
        _point.latitude > _destination!.latitude
            ? _point.latitude
            : _destination!.latitude,
        _point.longitude > _destination!.longitude
            ? _point.longitude
            : _destination!.longitude,
      ),
    );
    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _point,
          zoom: _destination == null ? 14 : 11,
        ),
        polylines: _polylines,
        markers: {
          Marker(
            markerId: const MarkerId('point'),
            position: _point,
            infoWindow: const InfoWindow(title: 'Start Point'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
          if (_destination != null)
            Marker(
              markerId: const MarkerId('destination'),
              position: _destination!,
              infoWindow: const InfoWindow(title: 'Destination'),
            ),
        },
      ),
    );
  }
}
