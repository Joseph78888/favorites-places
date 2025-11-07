import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_app/providers/user_places.dart';
import 'package:native_app/widgets/location_input.dart';

import 'package:native_app/widgets/pick_image.dart';

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
