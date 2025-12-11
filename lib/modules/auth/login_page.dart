import 'package:flutter/material.dart';
import 'package:lmg_app/data/models/property.dart';
import 'package:lmg_app/modules/booking/property_booking_page.dart';
import '../../data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  final Property? property;
  const LoginPage({super.key, this.property});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  bool _isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
    }
  }


 Future<void> login() async {
  if (!mounted) return;
  setState(() => loading = true);
  try {
    debugPrint('Login started');
    final res = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
        final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('password', _passwordController.text.trim());

    final token = await AuthService.getToken();
    if (token != null) {
       if (!mounted) return;
      if (widget.property != null) {
        // If a property was passed, replace the login page with the booking page.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PropertyBookingPage(property: widget.property!)),
        );
      } else {
        // Navigate to the HomePage, which will now handle showing the correct tab.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 0)),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      debugPrint('Login failed: ${res['message']}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Login failed')),
        );
      }
    }
  } catch (e, s) {
    debugPrint('Login error: $e\n$s');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Error: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => loading = false);
    }
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordObscured = !_isPasswordObscured);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Logging in...'),
                      ],
                    )
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
