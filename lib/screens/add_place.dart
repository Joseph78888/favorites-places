import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:native_app/providers/user_places.dart';
import 'package:native_app/widgets/location_input.dart';
import 'package:native_app/widgets/pick_image.dart';
/// A screen widget that lets the user enter and save a new "place".
///
/// This is a ConsumerStatefulWidget that composes a title input, an image
/// picker, and a location input. The collected data is validated and then
/// forwarded to the application state via the `userPlacesProvider`
/// notifier. On successful save the screen is dismissed.
///
/// UI overview:
///  - A TextField for the place title, managed by `_titleController`.
///  - A `PickImage` widget that returns a selected `File` stored in
///    `_selectedImage`.
///  - A `LocationInput` widget for selecting a place location (kept
///    separate from the state shown here).
///  - A full-width elevated button that triggers saving the place.
///
/// Behavior and validation:
///  - When the save action is triggered, the title must be non-empty and
///    an image must be selected. If either validation fails, the save is
///    aborted (a UI feedback hook is left commented in the code).
///  - On valid input, the screen calls:
///      ref.read(userPlacesProvider.notifier).addPlace(title, image)
///    then pops the current route to return to the previous screen.
///
/// Notes:
///  - The screen uses Riverpod's `ref` (via ConsumerState) to interact with
///    the provider layer.
///  - `_titleController` is cleaned up in `dispose` to avoid resource leaks.
///  - Error / empty-field feedback is currently implied but not shown; you
///    may want to replace the commented dialog with a proper user-facing
///    alert or inline validation message.

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;

  void _savePlace() {
    final enterdTitle = _titleController.text;
    if (enterdTitle.isEmpty || _selectedImage == null) {
      // showAboutDialog(
      //   context: context,

      //   // builder: (BuildContext context) {
      //   //   return Center(
      //   //     child: Container(
      //   //       color: Theme.of(context).colorScheme.primary,
      //   //       child: Text('Something went Wrong!'),
      //   //     ),
      //   //   );
      //   // },
      // );
      return;
    }
    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enterdTitle, _selectedImage!);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new Place')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.place_outlined),
                prefixIconColor: Theme.of(context).colorScheme.primary,

                label: Text(
                  'Title',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                hintText: 'My Home',
                hintStyle: TextStyle(color: Colors.grey),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              controller: _titleController,
            ),

            const SizedBox(height: 16),
            PickImage(
              onPickImage: (image) {
                _selectedImage = image;
              },
            ),
            const SizedBox(height: 16),
            LocationInput(),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _savePlace,
                icon: Icon(Icons.add),
                label: Text('Add Place'),
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
