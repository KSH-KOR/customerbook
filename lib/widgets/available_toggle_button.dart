import 'dart:developer';

import 'package:customermanager/services/product/productbook.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/appcolors.dart';

class AvailableToggleButton extends StatefulWidget {
  const AvailableToggleButton({super.key, required this.productId});

  final String productId;

  @override
  State<AvailableToggleButton> createState() => _AvailableToggleButtonState();
}

class _AvailableToggleButtonState extends State<AvailableToggleButton> {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductBook>(context, listen: false).findProductById(productId: widget.productId);
    if(product == null){
      log("cannot find product by id");
      return const Text("cannot find product by id");
    }
    return TextButton(
              onPressed: () async {
                product.isAvailable = !(product.isAvailable ?? false);
                setState(() {});
              },
              child: Text(
                (product.isAvailable ?? false) ? "available" : "unavailable",
                style: TextStyle(
                    color: product.isAvailable ?? false
                        ? AppColors.primaryColor
                        : AppColors.grayColor),
              ),
            );
  }
}