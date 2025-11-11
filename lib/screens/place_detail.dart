import 'package:flutter/material.dart';

import 'package:native_app/models/place.dart';
import 'package:native_app/screens/add_place.dart';

/// A stateless screen that displays detailed information for a given [Place].
///
/// This widget shows:
///  - The place title in the AppBar.
///  - The place image inside a rounded container with clipping and a Hero tag for
///    shared-element transitions (uses [place.id] as the Hero tag).
///  - An action button labeled "Add new fav place" that navigates to
///    [AddPlaceScreen] using `Navigator.pushReplacement`.
///
/// Constructor parameters:
///  - [place]: The [Place] model containing the data required to populate the UI
///    (e.g. `id`, `title`, and `image`). `place.image` is expected to be a valid
///    `File` that can be rendered by `Image.file`.
///
/// Layout and behavior notes:
///  - The image is displayed full width with a fixed height and `BoxFit.cover`,
///    clipped to a rounded rectangle (border radius 16).
///  - The Hero enables smooth transitions between routes that use the same tag.
///  - The action button is full-width, has a fixed height, and applies theme
///    colors for foreground/background. It replaces the current route when
///    navigating to the AddPlaceScreen.
///  - Consider adapting the hard-coded image height for different screen sizes
///    or using responsive constraints to avoid overflow on small devices.
///
/// Example:
/// ```dart
/// PlaceDetailScreen(place: myPlace);
/// ```


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
                  child: Hero(
                    tag: place.id,
                    child: Image.file(
                      place.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 770,
                    ),
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
