import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:native_app/providers/user_places.dart';
import 'package:native_app/providers/theme.dart';
import 'package:native_app/screens/add_place.dart';
import 'package:native_app/widgets/places_list.dart';
import 'package:shimmer/shimmer.dart';

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
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

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

            ListTile(
              title: Text('favorites'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    dismissDirection: DismissDirection.horizontal,
                    duration: Duration(seconds: 2),
                    content: Text('comming soon ^_^'),
                  ),
                );
              },
              leading: Icon(Icons.favorite_rounded),
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
        child: FutureBuilder(
          future: _placesFuture,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
              ? // Show shimmer placeholders while loading persisted places
                ListView.builder(
                  itemCount: 3,
                  itemBuilder: (ctx, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 14, color: Colors.white),
                                const SizedBox(height: 8),
                                Container(
                                  height: 10,
                                  width: 150,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : PlacesList(places: userPlaces),
        ),
      ),
    );
  }
}
