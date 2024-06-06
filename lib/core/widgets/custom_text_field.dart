import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.validator,
    this.onChanged,
    required this.keyboardType,
    required this.textCapitalization,
    required this.hintText,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? Function(String? value) validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: hintText,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 26.h,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        disabledBorder: _buildBorder(Colors.grey),
        focusedBorder: _buildBorder(),
        errorBorder: _buildBorder(Colors.red),
        focusedErrorBorder: _buildBorder(Colors.red),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.h),
      ),
      style: TextStyle(
        fontSize: 26.h,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    );
  }

  OutlineInputBorder _buildBorder([Color borderColor = Colors.black]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(width: 1.r, color: borderColor),
    );
  }
}
