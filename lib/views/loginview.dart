import 'package:customermanager/theme/appcolors.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "customer book",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const AddVerticalSpace(height: 20),
              const Text(
                "make your business easier",
                style: TextStyle(fontSize: 15),
              ),
              const AddVerticalSpace(height: 200),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                onPressed: () {
                  _authProvider.signInWithGoogle();
                },
                icon: const Icon(
                  Icons.login,
                  color: Colors.red,
                ),
                label: const Text("Continue with Google"),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                onPressed: () {
                  _authProvider.anonymouslogIn();
                },
                icon: const Icon(
                  Icons.login,
                  color: Colors.grey,
                ),
                label: const Text("Guest"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
