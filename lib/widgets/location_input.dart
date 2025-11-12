import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:native_app/constant/api_key.dart';
import 'package:native_app/models/place.dart';

/// A Flutter widget that allows the user to obtain and preview a geographic
/// location using the device's location services and the Google Maps/Geocoding
/// APIs.
///
/// This file provides a stateful widget, `LocationInput`, which:
/// - Requests and validates device location services and permissions using the
///   `location` package.
/// - Fetches the device's current geographic coordinates (latitude/longitude).
/// - Calls the Google Geocoding API to resolve a human-readable address for
///   the coordinates.
/// - Builds a URL for the Google Static Maps API to display a map image with a
///   marker at the chosen coordinates.
/// - Shows a preview area that displays:
///   - A placeholder message when no location is chosen.
///   - A static map image when a location is available (with a loading
///     indicator while the image loads).
///   - A bundled asset fallback image if the network map cannot be loaded.
/// - Provides two action buttons:
///   - "Get Current Location": attempts to detect the user's current location
///     and resolve an address (wired to an async handler).
///   - "Select on Map": placeholder for future map-selection functionality.
///
/// Notes on behavior and error handling:
/// - The widget uses a boolean `_isGettingLocation` to show a loading state
///   while the current location is being retrieved.
/// - Location service availability and permissions are checked and, if
///   necessary, requested interactively. If the service is disabled or the
///   permission is denied by the user, the location fetch is aborted.
/// - If coordinate retrieval fails or returns null coordinates, the method
///   aborts without updating state.
/// - When coordinates are available, the widget makes an HTTP GET request to
///   the Google Geocoding API to obtain a formatted address. If the request
///   fails or responses do not contain a usable address, an "Unknown location"
///   fallback address is used.
/// - Network and parsing errors are caught and handled: a SnackBar is shown
///   to inform the user that the location/address could not be fetched.
/// - The code ensures the loading indicator state (`_isGettingLocation`) is
///   cleared in a finally block, and only calls `setState` when the widget is
///   still mounted to avoid state-management errors.
///
/// Integration notes:
/// - This widget depends on:
///   - package:location for service/permission management and coordinate access.
///   - package:http for the Geocoding API call.
///   - a string `apiKye` (imported from a constants file) to build Google API
///     request URLs — ensure a valid API key is provided and the key name in
///     the constants matches this usage.
///   - a `PlaceLocation` model type used to hold latitude, longitude and
///     resolved address information.
/// - The Static Map URL generation and Geocoding request rely on Google web
///   APIs; ensure billing and API access are configured for the provided key.
/// - The widget references a local asset image path for fallback display; make
///   sure the asset exists and is declared in pubspec.yaml.
///
/// UI details:
/// - The preview area is a rounded container with a visible border and fixed
///   height. It displays either the map image, a progress indicator while the
///   image loads, a fallback asset on error, or a textual placeholder when no
///   location is selected.
/// - Buttons are rendered in a row below the preview with evenly distributed
///   spacing. The second "Select on Map" button is left intentionally unimplemented
///   for future extension (e.g. opening an interactive map screen).
///
/// Threading / async:
/// - All network and location operations are performed asynchronously and
///   awaited. UI state updates are performed via `setState` and guarded by the
///   widget's `mounted` flag where necessary to avoid updating unmounted widgets.

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  /// Returns a URL string for a Google Static Maps image representing the
  /// currently picked location.
  ///
  /// If `_pickedLocation` is null this getter returns the literal string
  /// `'not-found'`. Otherwise it constructs an HTTP URL that:
  ///  - centers the map on the picked latitude and longitude,
  ///  - uses zoom level 16,
  ///  - requests an image sized 600x300 pixels,
  ///  - uses the `roadmap` map type, and
  ///  - places a red marker labeled "A" at the location.
  ///
  /// The API key value referenced by `apiKye` must be set and valid for the
  /// returned URL to produce an actual map image. No network request is made
  /// by this getter — it only returns the encoded URL string suitable for use
  /// as an image source (for example in an Image.network call).
  ///
  /// Note: latitude and longitude are taken from `_pickedLocation.latitude`
  /// and `_pickedLocation.longitude` and are interpolated directly into the
  /// query parameters.
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

  /// Asynchronously obtains the device's current geographic location, performs
  /// reverse-geocoding via the Google Maps Geocoding API, and extracts a
  /// human-readable address.
  ///
  /// Workflow:
  /// - Ensures the device location service is enabled. If not enabled, requests
  ///   the user to enable it; returns early if the service remains disabled.
  /// - Ensures location permission is granted. If permission is denied, requests
  ///   permission and returns early if permission is not granted.
  /// - Sets the widget state flag `_isGettingLocation` to true (via setState)
  ///   to indicate a location fetch is in progress.
  /// - Attempts to read the current location (latitude/longitude) using the
  ///   Location package. Returns early if either coordinate is null.
  /// - Constructs a Google Geocoding API request URL (using the `apiKye` value),
  ///   issues an HTTP GET request, and parses the JSON response.
  /// - Extracts the first result's `formatted_address` when available; otherwise
  ///   falls back to a default string ("Unknown location").
  ///
  /// Side effects:
  /// - Mutates widget state (`_isGettingLocation`).
  /// - Performs network I/O and JSON decoding.
  /// - Prints/logs the generated URL and HTTP response (present in the snippet).
  ///
  /// Notes and considerations:
  /// - Ensure `apiKye` contains a valid Google API key and is stored securely.
  /// - Exceptions from location retrieval or network requests are executed
  ///   inside a try block in the snippet; verify that appropriate catch/finally
  ///   handling exists to reset state and surface errors to the user.
  /// - The snippet shown does not demonstrate resetting `_isGettingLocation`
  ///   after completion or error—add cleanup to avoid stale UI state.
  /// - Be mindful of runtime permission flows and long-running operations on
  ///   the UI thread; consider additional user feedback (e.g., error messages,
  ///   spinners) and cancellation handling as needed.
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
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
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
              label: Text(
                'Get Current Location',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
            ),
            SizedBox(width: 8),

            // second button
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.map),
              label: Text(
                'Select on Map',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
