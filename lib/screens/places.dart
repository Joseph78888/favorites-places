import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:native_app/providers/user_places.dart';
import 'package:native_app/providers/theme.dart';
import 'package:native_app/screens/add_place.dart';
import 'package:native_app/widgets/places_list.dart';

/// A screen that displays the user's saved places and provides basic settings.
///
/// This widget is a [ConsumerStatefulWidget] that integrates with Riverpod to
/// observe and control application state:
///  - Watches `userPlacesProvider` to obtain and render the current list of places.
///  - Watches `themeChangeNotifierProvider` to reflect and toggle the app's theme mode.
///
/// Responsibilities:
///  - Shows a [Scaffold] containing:
///    * a Drawer with a "Dark Mode" [SwitchListTile] that toggles between light
///      and dark theme modes by calling `themeProv.setThemeMode(...)` (this toggle
///      intentionally ignores the system theme),
///    * an AppBar titled "Your Places" with an add button that navigates to
///      [AddPlaceScreen] to create a new place,
///    * a padded body that displays the list of places via [PlacesList].
///
/// Lifecycle behavior:
///  - In `initState`, after the first frame is rendered, the widget triggers
///    `ref.read(userPlacesProvider.notifier).loadDummyPlaces()` to populate dummy
///    places if none exist. This ensures the UI has initial data for development
///    or demo scenarios without blocking the first frame.
///
/// Notes and usage:
///  - This screen depends on the following providers being available in the
///    widget tree: `userPlacesProvider` and `themeChangeNotifierProvider`.
///  - The UI elements (drawer, app bar, and list) are intentionally kept simple
///    and delegate actual data and theme mutations to their respective providers.

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  @override
  // void initState() {
  //   super.initState();
  //   // Populate dummy places once after first frame if none exist.
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.read(userPlacesProvider.notifier).loadDummyPlaces();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(userPlacesProvider);
    final themeProv = ref.watch(themeChangeNotifierProvider);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: themeProv.isDark,
              onChanged: (value) {
                // Toggle between light and dark (ignores system)
                themeProv.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              secondary: Icon(Icons.dark_mode),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Your Places'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PlacesList(places: userPlaces),
      ),
    );
  }
}
