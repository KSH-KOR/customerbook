import 'dart:developer';

import 'package:customermanager/services/auth/auth_provider.dart';
import 'package:customermanager/services/product/model/product.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/theme/appcolors.dart';
import 'package:customermanager/views/product/product_detail_view.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../services/file/const/cloud_directory_path.dart';
import '../../services/file/file_cloud_storage.dart';
import '../../widgets/image_selector.dart';
import '../../widgets/toggle_button.dart';

class AddNewProductView extends StatefulWidget {
  const AddNewProductView({super.key});

  @override
  State<AddNewProductView> createState() => _AddNewProductViewState();
}

class _AddNewProductViewState extends State<AddNewProductView> {
  late final TextEditingController nameTextEditingController;
  late final TextEditingController priceTextEditingController;
  late final TextEditingController descriptionTextEditingController;
  final List<bool> selectedOptions = [false, false];

  @override
  void initState() {
    nameTextEditingController = TextEditingController();
    priceTextEditingController = TextEditingController();
    descriptionTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    priceTextEditingController.dispose();
    descriptionTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productBook = Provider.of<ProductBook>(context);
    final fileCloudStorage = Provider.of<FileCloudStorage>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel_outlined),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const AddVerticalSpace(height: 20),
                ImageSwiper(imagePathOrUrl: fileCloudStorage.imageFileList, isPreview: true, height: 150,),
                const AddVerticalSpace(height: 50),
                TextField(
                  controller: nameTextEditingController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const AddVerticalSpace(height: 20),
                TextField(
                  controller: priceTextEditingController,
                  decoration: InputDecoration(
                    labelText: "price",
                    prefixIcon: const Icon(Icons.email),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const AddVerticalSpace(height: 20),
                TextField(
                  controller: descriptionTextEditingController,
                  decoration: InputDecoration(
                    labelText: "description",
                    prefixIcon: const Icon(Icons.phone_android),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const AddVerticalSpace(height: 10),
                ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    for (int i = 0; i < selectedOptions.length; i++) {
                        selectedOptions[i] = i == index;
                      }
                      
                    setState(() {
                      
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: AppColors.primaryColor,
                  selectedColor: Colors.white,
                  fillColor: AppColors.primaryColor,
                  color: AppColors.primaryColor,
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: selectedOptions,
                  children: const [Text("avilable"), Text("unavilable")],
                ),
                const AddVerticalSpace(height: 5),
                const ImageSelector(shouldPickMultiImages: true, msg: "Add product photos",),
              ],
            ),
          ),
        ),
        floatingActionButton: OutlinedButton(
          child: const Text("Add New Product"),
          onPressed: () async {
            if (productBook.userId == null) {
              log("error: user has not set in product book yet. \nfail to add new Product.");
              return;
            }
            if (productBook.userId != authProvider.currentUser!.id) {
              log("error: customerBook's user and auth user are different. \nfail to add new product.");
              return;
            }
            Navigator.of(context).pop();
            final productId = const Uuid().v4();
            final List<ProductImages> productImages = [];
            String? cloudImagePath;
            if (fileCloudStorage.imageFileList.isNotEmpty) {
              log("image uploadings to cloud has started");
              for (final imageLocalPath in fileCloudStorage.imageFileList) {
                cloudImagePath = '$productImageDirectoryPath/$productId';
                final imageId = const Uuid().v4();
                final downloadUrl = await fileCloudStorage.uploadFileToCloud(
                  fileFolderName: cloudImagePath,
                  fileName: imageId,
                  filePathFromLocalDevice: imageLocalPath,
                );
                productImages.add(ProductImages(
                    imageDownloadUrl: downloadUrl, imageId: imageId));
                log("image: [$imageId] download link is adding to cloud..");
              }
            }
            await productBook.createOrEidtProductToCloud(
              userId: productBook.userId!,
              name: nameTextEditingController.text != ""
                  ? nameTextEditingController.text
                  : null,
              price: priceTextEditingController.text != ""
                  ? priceTextEditingController.text
                  : null,
              description: descriptionTextEditingController.text != ""
                  ? descriptionTextEditingController.text
                  : null,
              isAvailable: selectedOptions[0],
              productId: productId,
              productImageCloudDirectoryPath: cloudImagePath,
              productImages: productImages,
            );
            fileCloudStorage.imageFileList = [];
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
