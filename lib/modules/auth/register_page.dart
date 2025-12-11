import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/property.dart';
import '../booking/property_booking_page.dart';
import '../home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() => loading = true);

    try {
      final res = await AuthService.register(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        phonenumber: _phoneController.text,
        acountnumber: _accountController.text,
        address: _addressController.text,
        profilePicture: profileImage,
      );

      // Check if the registration was successful based on the response.
      // This assumes your service returns a map with a 'success' key.
      if (res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        // Show the success message from the server
        if (mounted && res['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'])),
          );
        }
        await prefs.setString('email', _emailController.text.trim());
        await prefs.setString('password', _passwordController.text.trim());

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
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
