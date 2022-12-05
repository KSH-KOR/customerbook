import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class FileCloudStorage extends ChangeNotifier {
  final storageRef = FirebaseStorage.instance.ref();

  String? _imagePath;
  String? get imagePath => _imagePath;
  set imagePath(String? imagePath) {
    _imagePath = imagePath;
    notifyListeners();
  }

  List<String?> _imageFileList = [];
  List<String?> get imageFileList => _imageFileList;
  set imageFileList(List<String?> mewImageFileList) {
    _imageFileList = mewImageFileList;
    notifyListeners();
  }
  void setImageFileList(List<String>? selectedImages) {
    if (selectedImages == null) {
      log("warning: image file list has't been set because there is no selected image");
      return;
    }
    if (selectedImages.isEmpty) {
      log("warning: image file list has't been set because there is no selected image");
      return;
    }
    _imageFileList.clear();
    _imageFileList.addAll(selectedImages);
    notifyListeners();
  }

  Future<void> uploadMultipleFilesToCloud({
    List<String>? filesList,
    required String fileFolderName,
    required String fileName,
  }) async {
    if (filesList == null) {
      log("error: file list is null");
      return;
    }
    final targetRef = storageRef.child(fileFolderName);
    String filePath;
    File file;
    for (filePath in filesList) {
      file = File(filePath);
      try {
        await targetRef.child(fileName).putFile(file).then(
            (p0) => log("file uploaded on firecloud in this name $fileName"));
      } on FirebaseException catch (e) {
        log("file: [$fileName] cannot be uploaded. error msg:${e.code}");
      }
    }
  }

  Future<String?> uploadFileToCloud(
      {String? filePathFromLocalDevice,
      required String fileFolderName,
      required String fileName}) async {
    if (filePathFromLocalDevice == null) {
      log("error: file path is null. failed to upload file to cloud");
      return null;
    }
    final targetRef = storageRef.child(fileFolderName).child(fileName);
    final file = File(filePathFromLocalDevice);
    try {
      final uploadTask = targetRef.putFile(file);
      final taskSnapshot = await uploadTask;
      log("file uploaded on firecloud in this name $fileName");
      return await taskSnapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      log("cannot uploaded error msg:${e.code}");
      return null;
    }
  }

  Future<void> deleteFileOnCloud(
      {required String fileName, required String fileFolderName, bool isItFolder = false}) async {
    final targetRef = storageRef.child(fileFolderName).child(fileName);
    try {
      if(isItFolder){
        final referenceList = (await targetRef.listAll()).items;
        for(Reference ref in referenceList){
          await ref.delete();
        }
      } else{
        await targetRef.delete();
      }
      
      log("file deleted on firecloud: $fileName");
    } on FirebaseException catch (e) {
      log("cannot delete error msg:${e.code}. file path: ${targetRef.fullPath}");
    }
  }

  Future<void> updateFileToCloud(
      {required String path,
      required String fileFolderName,
      required String fileName}) async {
    final targetRef = storageRef.child(fileFolderName).child(fileName);
    final file = File(path);
    try {
      await targetRef.delete();
      await targetRef.putFile(file);
      log("file updated on firecloud in this name $fileName");
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "object-not-found":
          await targetRef.putFile(file);
          log("file coudn't find. So file created on firecloud in this name $fileName");
          break;
        default:
          log("cannot updated error msg:${e.code}");
      }
    }
  }

  Future<String?> getImageDownloadURL(
      {required String fileName, required String fileFolderName}) async {
    final targetRef = storageRef.child(fileFolderName).child(fileName);
    try {
      final String downloadLink = await targetRef.getDownloadURL();
      log("got file download link: $downloadLink");
      return downloadLink;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "object-not-found":
          log("file coudn't find in this name: $fileName \nfailed to get download link");
          return null;
        default:
          log("cannot updated error msg:${e.code}");
          return null;
      }
    }
  }

  Future<List<Future<String>>?> getAllImageDownloadUrl(
      {required String fileFolderDirectory}) async {
    final targetRef = storageRef.child(fileFolderDirectory);
    try {
      final listResult = await targetRef.listAll();
      final referenceList = listResult.items;
      return referenceList
          .map((e) async => (await e.getDownloadURL()))
          .toList();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "object-not-found":
          log("file coudn't find in this name: $fileFolderDirectory \nfailed to get download link");
          return null;
        default:
          log("cannot download download url. error msg:${e.code}");
          return null;
      }
    } catch (e) {
      log("cannot download download url. error msg:$e");
      return null;
    }
  }
}
