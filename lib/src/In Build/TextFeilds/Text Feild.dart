import 'package:flutter/material.dart';

Widget buildTextFieldContainer({
  required TextEditingController controller,
  required String hintText,
  String? labelText, // Optional label text
  TextInputType keyboardType = TextInputType.text,
  bool isEnabled = true,
  int maxLines = 1,
  Function(String)? onChanged, // Optional onChanged callback
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 3),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
    ),
    child: TextField(
      style: const TextStyle(
        fontSize: 16,
      ),
      controller: controller,
      enabled: isEnabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black), // fixed (was white)
        hintStyle: const TextStyle(fontSize: 14),
        border: InputBorder.none,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged, // Trigger the callback on text change
    ),
  );
}