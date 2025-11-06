import 'package:flutter/material.dart';

import 'package:native_app/models/place.dart';
import 'package:native_app/screens/place_detail.dart';

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
        leading: CircleAvatar(
          radius: 22,
          backgroundImage: FileImage(places[index].image),
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
