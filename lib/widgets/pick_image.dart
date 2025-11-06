import 'package:flutter/material.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  void _takePicture() {}
  @override
  Widget build(BuildContext context) {
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
      child: TextButton.icon(
        onPressed: _takePicture,
        icon: Icon(Icons.camera_alt_rounded),
        label: Text('Tack Picture'),
      ),
    );
  }
}
