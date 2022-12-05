
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/appcolors.dart';
import 'helpers.dart';

class WidgetDecorationFrame extends StatelessWidget {
  const WidgetDecorationFrame({super.key, required this.child, required this.header, this.maximumHeight = double.infinity, this.moreCallBackAction});

  final Widget child;
  final Widget header;
  final double maximumHeight;
  final VoidCallback? moreCallBackAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: maximumHeight),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: AppColors.cardBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              header,
              const Spacer(),
              Visibility(
                visible: moreCallBackAction != null,
                  child: TextButton(
                      onPressed: moreCallBackAction,
                      child: const Text(
                        "more",
                        style: TextStyle(color: AppColors.textColor),
                      ))),
            ],
          ),
          const AddVerticalSpace(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
