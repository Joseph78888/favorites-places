import 'package:flutter/material.dart';

import 'package:native_app/models/place.dart';
import 'package:native_app/screens/add_place.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentGeometry.bottomCenter,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.file(
                    place.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 770,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(MaterialPageRoute(builder: (ctx) => AddPlaceScreen()));
                },
                label: Text('Add new fav place'),
                icon: Icon(Icons.place_outlined),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
