import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';

import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';

class GoogleMapViewer extends StatefulWidget {
  const GoogleMapViewer({
    super.key,
    required this.point,
    this.destination,
    this.current,
    this.onRouteFetched,
  });
  final LatLng point;
  final LatLng? destination;
  final LatLng? current;
  final Function(List<LatLng>)? onRouteFetched;

  @override
  State<GoogleMapViewer> createState() => _GoogleMapViewerState();
}

class _GoogleMapViewerState extends State<GoogleMapViewer> {
  GoogleMapController? mapController;

  late LatLng _point;
  late LatLng? _destination;
  late LatLng? _current;

  final Set<Polyline> _polylines = {};
  bool _routeFetched = false;

  BitmapDescriptor? _unicornPin;

  @override
  void initState() {
    super.initState();
    _point = widget.point;
    _destination = widget.destination;
    _current = widget.current;

    if (_destination != null) {
      _fetchRoute();
    }
  }

  @override
  void didUpdateWidget(GoogleMapViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.point != oldWidget.point ||
        widget.destination != oldWidget.destination ||
        widget.current != oldWidget.current) {
      setState(() {
        _point = widget.point;
        _destination = widget.destination;
        _current = widget.current;
      });
      if (_destination != null && _destination != oldWidget.destination) {
        _routeFetched = false;
        _fetchRoute();
        _animateCameraToBounds();
      } else {
        try {
          mapController?.animateCamera(
            CameraUpdate.newLatLng(_current ?? _point),
          );
        } catch (e) {
          Log.echo('Error: $e');
        }
      }
    }
  }

  Future<void> _fetchRoute() async {
    _unicornPin = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        Assets.images.icons.unicornPin.path);
    if (_routeFetched) return; // Prevent multiple calls
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
        _routeFetched = true;
      });
      if (widget.onRouteFetched != null) {
        widget.onRouteFetched!(points);
      }
    } catch (e) {
      Log.echo('Error fetching route: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_current != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(_current!),
      );
    } else if (_destination != null) {
      _animateCameraToBounds();
    } else {
      controller.animateCamera(
        CameraUpdate.newLatLng(_point),
      );
    }
  }

  void _animateCameraToBounds() {
    List<LatLng> locations = [_point];
    if (_destination != null) locations.add(_destination!);

    double south =
        locations.map((loc) => loc.latitude).reduce((a, b) => a < b ? a : b);
    double west =
        locations.map((loc) => loc.longitude).reduce((a, b) => a < b ? a : b);
    double north =
        locations.map((loc) => loc.latitude).reduce((a, b) => a > b ? a : b);
    double east =
        locations.map((loc) => loc.longitude).reduce((a, b) => a > b ? a : b);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    try {
      mapController?.animateCamera(
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
          zoom: 15,
        ),
        polylines: _polylines,
        markers: {
          if (_current != null)
            Marker(
              markerId: const MarkerId('現在地'),
              position: _current!,
              infoWindow: const InfoWindow(title: '現在地'),
              icon: _unicornPin ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
            ),
          Marker(
            markerId: const MarkerId('Unicorn出発地点'),
            position: _point,
            infoWindow: const InfoWindow(title: 'Unicorn出発地点'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
          if (_destination != null)
            Marker(
              markerId: const MarkerId('要請先'),
              position: _destination!,
              infoWindow: const InfoWindow(title: '要請先'),
            ),
        },
      ),
    );
  }
}
