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
  PlaceDetailScreen({super.key, required this.place});
  final Place place;
  final List<Place> favoritePlaces = [];

  void _addToFavorites(Place place) {
    favoritePlaces.add(place);
    print('=======================');
    // You might want to show a confirmation message or update the UI accordingly.
  }

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
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  // top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: AlignmentGeometry.topCenter,
                        end: AlignmentGeometry.bottomCenter,
                      ),
                    ),
                    width: double.infinity,
                    height: 220,

                    // clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assest/images/map.png'),
                          maxRadius: 70,
                        ),
                        SizedBox(height: 16),
                        Text(
                          ' Your image addres will appear here',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                        Text(
                          'make sure you picked the correct location',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (ctx) => AddPlaceScreen()),
                        );
                      },
                      label: Text('Add new fav place'),
                      icon: Icon(Icons.place_outlined),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),

                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(200),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            dismissDirection: DismissDirection.horizontal,
                            duration: Duration(seconds: 2),
                            content: Text('comming soon ^_^'),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
