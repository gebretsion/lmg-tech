import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lmg_app/modules/home/home_page.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/property.dart';
import '../booking/property_booking_page.dart';
import '../../routes/app_routes.dart'; // Import AppRoutes for navigation

class RegisterPage extends StatefulWidget {
  final Property? property;
  const RegisterPage({super.key, this.property});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  File? profileImage;
  bool loading = false;
  bool _isPasswordObscured = true;

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => profileImage = File(image.path));
  }

  Future<void> register() async {
    if (profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await AuthService.register(
        email: email,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        phonenumber: _phoneController.text,
        acountnumber: _accountController.text,
        address: _addressController.text,
        profilePicture: profileImage,
      );

      // If AuthService.register completes without throwing an exception, it's successful.
      // The AuthService.register method now handles saving the token and user data.
      if (res != null) { // res will not be null if no exception was thrown
        // Show the success message from the server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'])),
          );
        }
        if (!mounted) return;

        if (widget.property != null) {
          // If a property was passed, replace the register page with the booking page.
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
        // If registration was not successful, show the message from the server.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        String message = 'Error: $e';
        if (e is SocketException) {
          message = 'Network error: Check your internet connection or server URL.';
        }
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email')),
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
                )),
            TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
                controller: _accountController,
                decoration:
                    const InputDecoration(labelText: 'Account Number')),
            TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address')),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : register,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
