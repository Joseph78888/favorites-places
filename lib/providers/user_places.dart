import 'dart:io';

// import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/legacy.dart';
// persistence to device disabled by request: commenting out related imports
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';

import 'package:native_app/models/place.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []) {
    // Persistence disabled: do not load from device. Keep in-memory state only.
    _isLoading = false;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  /// Add a place: copy the provided image into the app documents directory
  /// so it persists, update state and save to SharedPreferences.
  Future<void> addPlace(
    String title,
    File image /* PlaceLocation location */,
  ) async {
    // Device persistence disabled: keep the provided File reference in-memory
    final newPlace = Place(title: title, image: image);
    state = [newPlace, ...state];
    _isLoading = false;
  }

  /// Load three dummy places by copying an example asset into temporary files.
  /// This is safe to call multiple times; it only populates when state is empty.
  // Future<void> loadDummyPlaces() async {
  //   if (state.isNotEmpty) return;

  //   try {
  //     final titles = ['Example', 'Home', 'Nice place'];

  //     for (var i = 0; i < titles.length; i++) {
  //       // Try to download a distinct placeholder image (picsum) for each entry.
  //       File file;
  //       try {
  //         final uri = Uri.parse('https://picsum.photos/seed/place_$i/600/300');
  //         final resp = await http.get(uri);
  //         if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
  //           file = File('${Directory.systemTemp.path}/native_app_dummy_place_$i.png');
  //           await file.writeAsBytes(resp.bodyBytes);
  //           await addPlace(titles[i], file);
  //           continue;
  //         }
  //       } catch (_) {
  //         // ignore and try asset fallback
  //       }

  //       // Fallback to bundled asset if download fails
  //       try {
  //         final data = await rootBundle.load('assest/images/map.png');
  //         final bytes = data.buffer.asUint8List();
  //         file = File('${Directory.systemTemp.path}/native_app_dummy_map_$i.png');
  //         await file.writeAsBytes(bytes);
  //         await addPlace(titles[i], file);
  //       } catch (_) {
  //         // If even fallback fails, skip adding this place.
  //       }
  //     }
  //   } catch (e) {
  //     // If asset copy fails, leave state empty — app will still work and user can add places.
  //   }
  // }

  // Persistence helpers are disabled. The app will not save places to device.

  /// Remove a place by id. Returns the removed Place if found.
  Future<Place?> removePlace(String id) async {
    final idx = state.indexWhere((p) => p.id == id);
    if (idx < 0) return null;
    final removed = state[idx];
    state = [...state]..removeAt(idx);
    // delete the image file if it exists
    try {
      if (removed.image.existsSync()) {
        await removed.image.delete();
      }
    } catch (_) {}
    return removed;
  }

  /// Restore a previously removed place (inserts at front) without copying image.
  Future<void> restorePlace(Place place) async {
    state = [place, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
