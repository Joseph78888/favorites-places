import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:native_app/models/place.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []) {
    _isLoading = true;
    _loadFromPrefs();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Add a place: copy the provided image into the app documents directory
  /// so it persists, update state and save to SharedPreferences.
  Future<void> addPlace(String title, File image, /* PlaceLocation location */) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'place_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image.copy('${appDir.path}/$fileName');

      final newPlace = Place(title: title, image: savedImage);
      state = [newPlace, ...state];
      await _saveToPrefs();
    } catch (e) {
      // Fallback: use original image if copy fails
      final newPlace = Place(title: title, image: image);
      state = [newPlace, ...state];
      await _saveToPrefs();
    }
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
            await addPlace(titles[i], file);
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
          await addPlace(titles[i], file);
        } catch (_) {
          // If even fallback fails, skip adding this place.
        }
      }
    } catch (e) {
      // If asset copy fails, leave state empty — app will still work and user can add places.
    }
  }

  // --- persistence helpers ---
  static const _kPlacesPrefsKey = 'user_places';

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = state.map((p) => json.encode({
            'id': p.id,
            'title': p.title,
            'image': p.image.path,
          })).toList();
      await prefs.setStringList(_kPlacesPrefsKey, encoded);
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    try {
      _isLoading = true;
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kPlacesPrefsKey);
      if (list == null || list.isEmpty) return;
      final loaded = <Place>[];
      for (final s in list) {
        try {
          final map = json.decode(s) as Map<String, dynamic>;
          final imagePath = map['image'] as String?;
          final title = map['title'] as String?;
          final id = map['id'] as String?;
          if (imagePath == null || title == null) continue;
          final imgFile = File(imagePath);
          if (!imgFile.existsSync()) continue;
          loaded.add(Place(id: id, title: title, image: imgFile));
        } catch (_) {}
      }
      if (loaded.isNotEmpty) {
        state = loaded;
      }
      _isLoading = false;
      // notify listeners by forcing a state update (same list) so UI depending on notifier.isLoading rebuilds
      state = [...state];
    } catch (_) {}
  }

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
    await _saveToPrefs();
    return removed;
  }

  /// Restore a previously removed place (inserts at front) without copying image.
  Future<void> restorePlace(Place place) async {
    state = [place, ...state];
    await _saveToPrefs();
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
