import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const TextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(222, 117, 117, 117), fontSize: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color.fromARGB(255, 149, 162, 237)) : null,
        filled: true,
        fillColor: const Color.fromARGB(246, 212, 210, 227),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}