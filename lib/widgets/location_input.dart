import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:native_app/constant/api_key.dart';
import 'package:native_app/models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return 'not-found';
    }
    final lat = _pickedLocation!.latitude;
    final lon = _pickedLocation!.longitude;
    return Uri.parse(
      'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lon&key=$apiKye',
    ).toString();
  }

  void _getCurrentUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        // No valid coordinates, nothing to do.
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKye',
      );

      final response = await http.get(url);

      String address = 'Unknown location';
      if (response.statusCode == 200) {
        final responseData =
            json.decode(response.body) as Map<String, dynamic>?;
        final results = responseData?['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>?;
          address = (first != null && first['formatted_address'] != null)
              ? first['formatted_address'] as String
              : address;
        }
      }

      // Update picked location with a safe address value
      setState(() {
        _pickedLocation = PlaceLocation(
          latitude: lat,
          longitude: lon,
          address: address,
        );
      });
    } catch (error) {
      // Optionally inform the user; for now show a small message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch location/address.')),
        );
      }
    } finally {
      // Ensure we always clear the loading indicator.
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      } else {
        _isGettingLocation = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen!',
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Show progress while the image is loading
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        // Handle HTTP errors (403, 404, etc.) gracefully
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assest/images/map.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

          // return Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.map_outlined,
          //         size: 48,
          //         color: Theme.of(context).colorScheme.primary,
          //       ),
          //       SizedBox(height: 8),
          //       Text(
          //         'Could not load map',
          //         style: TextStyle(color: Theme.of(context).colorScheme.primary),
          //       ),
          //     ],
          //   ),
          // );
        },
      );
    }

    if (_isGettingLocation) {
      previewContent = CircularProgressIndicator();
    }

    return Column(
      children: [
        // placeholder for map image
        Container(
          height: 200,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.hardEdge,
          child: previewContent,
        ),
        SizedBox(height: 12),

        // location buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // first button
            OutlinedButton.icon(
              onPressed: _getCurrentUserLocation,
              icon: Icon(Icons.location_on_rounded),
              label: Text('Get Current Location'),
            ),
            SizedBox(width: 20),

            // second button
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.map),
              label: Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
