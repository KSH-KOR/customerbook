

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _authProvider.signInWithGoogle();
                      },
                      icon: const Icon(
                        Icons.login,
                        color: Colors.red,
                      ),
                      label: const Text("GOOGLE"),
                    ),
                    
                    ElevatedButton.icon(
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