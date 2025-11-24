import 'package:flutter/material.dart';
import 'package:lmg_app/modules/auth/login_page.dart';
import 'package:lmg_app/modules/auth/register_page.dart';

class LoginTab extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginTab({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage()),
                );
                if (result == true) onLoginSuccess();
              },
              child: const Text('Go to Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPage()),
                );
                if (result == true) onLoginSuccess();
              },
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}