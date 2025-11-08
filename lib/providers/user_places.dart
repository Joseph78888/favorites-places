// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/legacy.dart';

import 'package:native_app/models/place.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addPlace(String title, File image, /* PlaceLocation location */) {
    final newPlace = Place(title: title, image: image, /* location: location */);
    state = [newPlace, ...state];
  }

  /// Load three dummy places by copying an example asset into temporary files.
  /// This is safe to call multiple times; it only populates when state is empty.
  Future<void> loadDummyPlaces() async {
    if (state.isNotEmpty) return;

    try {
      final titles = ['Example', 'Home', 'Nice place'];

      for (var i = 0; i < titles.length; i++) {
        // Try to download a distinct placeholder image (picsum) for each entry.
        File file;
        try {
          final uri = Uri.parse('https://picsum.photos/seed/place_$i/600/300');
          final resp = await http.get(uri);
          if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
            file = File('${Directory.systemTemp.path}/native_app_dummy_place_$i.png');
            await file.writeAsBytes(resp.bodyBytes);
            addPlace(titles[i], file);
            continue;
          }
        } catch (_) {
          // ignore and try asset fallback
        }

        // Fallback to bundled asset if download fails
        try {
          final data = await rootBundle.load('assest/images/map.png');
          final bytes = data.buffer.asUint8List();
          file = File('${Directory.systemTemp.path}/native_app_dummy_map_$i.png');
          await file.writeAsBytes(bytes);
          addPlace(titles[i], file);
        } catch (_) {
          // If even fallback fails, skip adding this place.
        }
      }
    } catch (e) {
      // If asset copy fails, leave state empty — app will still work and user can add places.
    }
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
