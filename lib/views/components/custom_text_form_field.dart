import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? inputValidator;
  final TextInputType inputType;
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.inputValidator,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: inputValidator,
      decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))),
      keyboardType: inputType,
    );
  }
}
