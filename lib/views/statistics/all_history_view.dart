
import 'package:customermanager/views/statistics/sales_statistics_view.dart';
import 'package:customermanager/widgets/widget_decoration_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../theme/appcolors.dart';
import '../../widgets/helpers.dart';

class AllHistoryView extends StatelessWidget {
  const AllHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: const [
            AddVerticalSpace(height: 20),
            ShowCustomerRecentPurchaseButtonList(),
            AddVerticalSpace(height: 20),
            Expanded(
              child: WidgetDecorationFrame(
                header: Text("all history"),
                child: PurchasesDatatable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}