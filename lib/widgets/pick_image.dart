import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A stateful widget that provides a simple image-capture UI using the device camera.
///
/// The widget shows a prominent rounded container. When no image is selected it displays
/// a "Take Picture" button; after the user takes a picture it shows a full-coverage preview
/// of the captured image and allows the user to tap the preview to retake the photo.
///
/// The widget uses the image_picker package to open the camera and returns the selected
/// image as a `dart:io` `File` to the caller via the [onPickImage] callback.
///
/// Typical usage:
/// ```dart
/// PickImage(
///   onPickImage: (file) {
///     // handle the selected image file
///   },
/// )
/// ```

class PickImage extends StatefulWidget {
  const PickImage({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File? _selectedImage;
  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: _takePicture,
      icon: Icon(Icons.camera_alt_rounded),
      label: Text('Take Picture'),
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Container(
      height: 320,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
