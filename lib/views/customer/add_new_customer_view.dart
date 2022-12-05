import 'dart:developer';

import 'package:customermanager/services/auth/auth_provider.dart';
import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/theme/appcolors.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../services/customer/model/customer.dart';
import '../../services/file/const/cloud_directory_path.dart';
import '../../services/file/file_cloud_storage.dart';
import '../../widgets/image_selector.dart';

class AddNewCustomerView extends StatefulWidget {
  const AddNewCustomerView({super.key});

  @override
  State<AddNewCustomerView> createState() => _AddNewCustomerViewState();
}

class _AddNewCustomerViewState extends State<AddNewCustomerView> {

  late final TextEditingController nameTextEditingController;
  late final TextEditingController emailTextEditingController;
  late final TextEditingController phoneNumberTextEditingController;

  @override
  void initState() {
    nameTextEditingController = TextEditingController();
    emailTextEditingController = TextEditingController();
    phoneNumberTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    phoneNumberTextEditingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    
    final customerBook = Provider.of<CustomerBook>(context);
    final fileCloudStorage = Provider.of<FileCloudStorage>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text("Add new customer"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
              fileCloudStorage.imagePath = null;
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const AddVerticalSpace(height: 20),
                InkWell(
                  onTap: const ImageSelector().selectAction(fileCloudStorage),
                  child: AvatarProfile(
                    profileImageUrl: fileCloudStorage.imagePath,
                    isLocalPath: true,
                    width: 150,
                    height: 150,
                  ),
                ),
                const AddVerticalSpace(height: 50),
                TextField(
                  controller: nameTextEditingController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1, color: Colors.grey),
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
                  controller: emailTextEditingController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    prefixIcon: Icon(Icons.email),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1, color: Colors.grey),
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
                  controller: phoneNumberTextEditingController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: const Icon(Icons.phone_android),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1, color: Colors.grey),
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
                const ImageSelector(msg: "Add Profile Photo"),
              ],
            ),
          ),
        ),
        floatingActionButton: OutlinedButton(
            
            child: const Text("Add New Customer"),
            onPressed: () async {
              if(customerBook.userId == null){
                log("error: [customer book]: user is null. \nfail to add new customer.");
                return;
              }
              if(customerBook.userId != authProvider.currentUser!.id){
                log("error: customerBook's user and auth user are different. \nfail to add new customer.");
                return;
              }
              final customerId = const Uuid().v4();
              String? downloadUrlFromCloud;
              Navigator.of(context).pop();
              if(fileCloudStorage.imagePath != null){
                await fileCloudStorage.uploadFileToCloud(filePathFromLocalDevice: fileCloudStorage.imagePath, fileFolderName: customerProfileImageDirectoryPath, fileName: customerId);
                downloadUrlFromCloud = await fileCloudStorage.getImageDownloadURL(fileFolderName: customerProfileImageDirectoryPath, fileName: customerId);
              }
              await customerBook.createOrEidtCustomerToCloud(
                customerId: customerId,
                  userId: customerBook.userId!,
                  name: nameTextEditingController.text.isNotEmpty ? nameTextEditingController.text : null,
                  email: emailTextEditingController.text.isNotEmpty ? emailTextEditingController.text : null,
                  phoneNumber: phoneNumberTextEditingController.text.isNotEmpty ? phoneNumberTextEditingController.text : null,
                  profileImageUrl: downloadUrlFromCloud,
                  isFavorited: false,);
              fileCloudStorage.imagePath = null;
            },),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
