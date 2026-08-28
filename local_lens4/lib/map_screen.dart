import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'guide_model.dart';

class MapScreen extends StatelessWidget {
  final List<Guide> guides;

  const MapScreen({super.key, required this.guides});

  @override
  Widget build(BuildContext context) {
    if (guides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Guide Locations')),
        body: const Center(child: Text('No guide locations available.')),
      );
    }

    final center = LatLng(guides.first.latitude, guides.first.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Locations'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: guides.map((guide) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(guide.latitude, guide.longitude),
                child: Tooltip(
                  message: '${guide.name}\n${guide.bio}',
                  child: const Icon(
                    Icons.location_pin,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}