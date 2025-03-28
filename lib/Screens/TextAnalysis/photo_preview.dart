import 'dart:io';
import 'package:flutter/material.dart';
import '../../Utilities/constants.dart';

class PhotoPreview extends StatelessWidget {
  final String imagePath;

  const PhotoPreview({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Align(
        alignment: Alignment.topCenter,
        child:
            (imagePath.isNotEmpty && imagePath != '')
                ? Image.file(
                  File(imagePath),
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : const Text(
                  "No image available",
                  style: TextStyle(color: AppColors.text),
                ),
      ),
    );
  }
}
