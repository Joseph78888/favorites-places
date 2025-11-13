import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:native_app/models/place.dart';

Future<Database> _getDataBase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    // Open the database at a given path
    path.join(
      dbPath,
      'places.db',
    ), //Joins the given path parts into a single path using the current platform's [separator]
    onCreate: (db, version) {
      return db.execute(
        // Execute an SQL query with no return value.
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT)',
      );
    },
    version:
        1, //[version] (optional) specifies the schema version of the database being opened. This is used to decide whether to call [onCreate], [onUpgrade], and [onDowngrade]
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDataBase();
    final data = await db.query('user_places');
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            image: File(row['image'] as String),
            title: row['title'] as String,
          ),
        )
        .toList();
    state = places;
  }

  /// Add a place: copy the provided image into the app documents directory
  /// so it persists, update state and save to SharedPreferences.
  Future<void> addPlace(
    String title,
    File image /* PlaceLocation location */,
  ) async {
    // Device persistence disabled: keep the provided File reference in-memory
    final appDir = await syspaths
        .getApplicationDocumentsDirectory(); //Path to a directory where the application may place data that is user-generated

    final fileName = path.basename(
      image.path,
    ); // Gets the part of [path] after the last separator.

    final copiedImage = await image.copy(
      '${appDir.path}/$fileName',
    ); // Copies this file.

    final newPlace = Place(title: title, image: copiedImage);

    final db = await _getDataBase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
    });

    state = [newPlace, ...state];
  }

 

}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
