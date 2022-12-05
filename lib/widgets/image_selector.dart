import 'dart:developer';

import 'package:customermanager/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/file/file_cloud_storage.dart';

class ImageSelector extends StatelessWidget {
  const ImageSelector({super.key, this.defaultImageURL, this.shouldPickMultiImages = false, this.msg = "Add Photo"});

  final String? defaultImageURL;
  final bool shouldPickMultiImages;
  final String msg;

  Future<String?> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      return image.path;
    } on PlatformException catch (e) {
      log('Failed to pick image: $e');
    }
    return null;
  }

  Future<List<String>?> _selectImages() async {
    try {
      final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
      if(selectedImages == null){
        log('Failed to pick images');
        return null;
      }
      return selectedImages.map((e) => e.path,).toList();
    } on PlatformException catch (e) {
      log('Failed to pick image: $e');
    }
  }

  VoidCallback selectAction(FileCloudStorage fileProvider){
    return () async {
          if(shouldPickMultiImages){
            final pickedFilePaths = await _selectImages();
            fileProvider.setImageFileList(pickedFilePaths);
          } else{
            final pickedFilePath = await pickImage();
            fileProvider.imagePath = pickedFilePath;
          }
    };
  }
  @override
  Widget build(BuildContext context) {
    final fileProvider =
        Provider.of<FileCloudStorage>(context, listen: true);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: OutlinedButton(
        onPressed: () async {
          if(shouldPickMultiImages){
            final pickedFilePaths = await _selectImages();
            fileProvider.setImageFileList(pickedFilePaths);
          } else{
            final pickedFilePath = await pickImage();
            fileProvider.imagePath = pickedFilePath;
          }
        },
        child: Text(msg, style: TextStyle(color: AppColors.primaryColor)),
      ),
    );
  }
}
