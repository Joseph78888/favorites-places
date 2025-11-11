import 'package:flutter/material.dart';

import 'package:native_app/models/place.dart';
import 'package:native_app/screens/place_detail.dart';

/// A stateless widget that renders a scrollable list of places.
///
/// Displays the provided list of [Place] objects using a [ListView.builder].
/// - If [places] is empty, a centered informational message is shown instead of
///   the list.
/// - Each non-empty entry is rendered as a [ListTile] containing:
///   - A circular avatar on the leading edge showing the place image using
///     a [FileImage].
///   - The place title as the tile's main text, styled with the current theme.
///   - A subtitle describing the selection (small, themed text).
///   - A trailing forward arrow icon to indicate navigation.
///
/// Visual and navigation behavior:
/// - The avatar is wrapped in a [Hero] widget using the place's `id` as the
///   hero tag to enable shared-element transitions to the detail screen. Ensure
///   `id` values are unique across the app to avoid hero conflicts.
/// - Tapping a tile pushes a [PlaceDetailScreen] onto the navigation stack via
///   `Navigator.of(context).push(MaterialPageRoute(...))`, passing the tapped
///   [Place] as an argument.
///
/// Parameters:
/// - [places] (required): The list of places to render. Each item is expected
///   to contain an `id`, `title`, and a local image file compatible with
///   [FileImage]. An empty list triggers the empty-state message.
///
/// Notes:
/// - Text styles and colors are derived from `Theme.of(context)` to match the
///   surrounding app styling.
/// - [ListView.builder] is used for efficient, lazily-built list items for
///   better performance with long lists.

class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.places});
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Center(
        child: Text(
          '        No Places Added Yet!\n'
          'try press + putton and add one',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: Hero(
          // transitionOnUserGestures: true,
          tag: places[index].id,
          child: CircleAvatar(
            radius: 22,
            backgroundImage: FileImage(places[index].image),
          ),
        ),

        title: Text(
          places[index].title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        subtitle: Text(
          'you added "${places[index].title}" as fav place',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),

        trailing: Icon(Icons.arrow_forward_ios),

        style: ListTileStyle.drawer,

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PlaceDetailScreen(place: places[index]),
            ),
          );
        },
      ),
    );
  }
}
