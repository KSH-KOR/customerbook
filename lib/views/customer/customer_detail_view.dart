import 'dart:developer';

import 'package:customermanager/constants/routes.dart';
import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/services/file/file_cloud_storage.dart';
import 'package:customermanager/theme/appcolors.dart';
import 'package:customermanager/views/customer/navigation_pages/history.dart';
import 'package:customermanager/widgets/dialogs/call_dialog.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:customermanager/widgets/widget_decoration_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

import '../../services/customer/model/customer.dart';
import '../../services/file/const/cloud_directory_path.dart';
import '../../widgets/dialogs/delete_dialog.dart';
import '../../widgets/dialogs/no_mail_found_dialog.dart';

import 'package:intl/intl.dart' show DateFormat;

enum MenuAction { delete, edit }

class CustomerDetailView extends StatefulWidget {
  const CustomerDetailView({super.key});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {

  final pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    late final String arg;
    try {
      arg = ModalRoute.of(context)!.settings.arguments as String;
    } catch (e) {
      log("detail page: got wrong argument. error msg:$e");
      Navigator.of(context).pop();
    }
    final Customer? customer = Provider.of<CustomerBook>(context, listen: false)
        .findCustomerById(customerId: arg);
    if (customer == null) {
      log("customer detail page: customer info missing");
      Navigator.of(context).pop();
    }
    final customrBook = Provider.of<CustomerBook>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
            await Provider.of<CustomerBook>(context, listen: false)
                .editCustomerToCloud(
                    customerId: customer!.customerId,
                    isFavorited: customer.isFavorited);
          },
        ),
        actions: [
          PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.delete:
                      final shouldDelete = await showDeleteDialog(context,
                          'Are you sure you want to delete this customer?');
                      if (shouldDelete) {
                        customrBook
                            .removeCustomerToCloud(
                                customerId: customer!.customerId)
                            .then(
                          (value) async {
                            Navigator.of(context).pop();
                            if (customer.profileImageUrl != null) {
                              await Provider.of<FileCloudStorage>(context,
                                      listen: false)
                                  .deleteFileOnCloud(
                                      fileName: customer.customerId,
                                      fileFolderName:
                                          customerProfileImageDirectoryPath);
                            }
                          },
                        );
                      }
                      break;
                    case MenuAction.edit:
                      // TODO: Handle this case.
                      break;
                  }
                },
                itemBuilder: (contest) {
                  return const [
                    PopupMenuItem<MenuAction>(
                        value: MenuAction.edit, child: Text("Edit")),
                    PopupMenuItem<MenuAction>(
                        value: MenuAction.delete, child: Text("Delete")),
                  ];
                },
              ),
              
        ],
      ),
      body: Column(
          children: [
            customer!.getProfileImage(height: 120, width: 120),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(customer.name ?? "no name"),
                const AddHorizontalSpace(width: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero, // Set this
                    padding: EdgeInsets.zero, // and this
                  ),
                  onPressed: () async {
                    customer.isFavorited = !customer.isFavorited;
                    setState(() {});
                  },
                  child: Text(
                    "favorite",
                    style: TextStyle(
                        color: customer.isFavorited
                            ? AppColors.primaryColor
                            : AppColors.grayColor),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ScrollNavigation(
                bodyStyle: const NavigationBodyStyle(
                  background: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                barStyle: const NavigationBarStyle(
                  background: Colors.white,
                  elevation: 0.0,
                ),
                pages: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ContactInformationSheet(customer: customer),
                  ),
                  const CustomerHistoryPage(),
                ],
                items: const [
                  ScrollNavigationItem(icon: Icon(Icons.people)),
                  ScrollNavigationItem(icon: Icon(Icons.receipt)),
                ],
                pagesActionButtons: [
                  const SizedBox.shrink(),
                  FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(addNewHistoryRoute,
                          arguments: customer.customerId);
                  },
                ),
                ],
              ),
            ),
          ],
        ),
      
      
      
    );
  }
}

class ContactInformationSheet extends StatelessWidget {
  const ContactInformationSheet({
    Key? key,
    required this.customer,
  }) : super(key: key);

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Contact Information"),
          const AddVerticalSpace(height: 20),
          InformationCard(
            title: "Email Address:",
            contents: customer.email ?? "no email",
            trailing: Visibility(
              visible: customer.email != null,
              child: IconButton(icon: const Icon(Icons.email), onPressed: () async {
                OpenMailApp.openMailApp().then((result) async {
                  if (!result.didOpen && !result.canOpen) {
                    showNoMailAppsDialog(context);
                  } else if (!result.didOpen && result.canOpen) {
                    await showDialog(
                      context: context,
                      builder: (_) {
                        return MailAppPickerDialog(
                          mailApps: result.options,
                        );
                      },
                    );
                  }
                });
                // Android: Will open mail app or show native picker.
                // iOS: Will open mail app if single mail app found.
                // If no mail apps found, show error
              
              },),
            ),
          ),
          const AddVerticalSpace(height: 20),
          InformationCard(
            title: "Phone Number:",
            contents: customer.phoneNumber ?? "no phone number",
            trailing: Visibility(
              visible: customer.phoneNumber != null,
              child: IconButton(
                icon: const Icon(Icons.phone), onPressed: () async {
                  final shouldCall = await showCallDialog(context, "Do you want to call in this number? [${customer.phoneNumber!}]");
                  if(shouldCall) FlutterPhoneDirectCaller.callNumber(customer.phoneNumber!);
              },),
            ),
          ),
          const AddVerticalSpace(height: 20),
          InformationCard(
              title: "register date:",
              contents: DateFormat("yyyy-MM-dd").format(
                  DateTime.fromMicrosecondsSinceEpoch(
                      customer.registerDate.microsecondsSinceEpoch))),
        ],
      ),
    );
  }
}

class InformationCard extends StatelessWidget {
  const InformationCard({
    Key? key,
    required this.title,
    required this.contents,
    this.trailing
  }) : super(key: key);

  final String title;
  final String contents;
  final Widget? trailing;
  

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
              Text(contents),
            ],
          ),
          const Spacer(),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
