import 'package:flutter/material.dart';
import 'glass_container.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  const SearchField({
    super.key,
    this.hintText = 'Cari...',
    required this.onChanged,
    this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      borderRadius: 16,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Color(0xFF1E1E38), fontSize: 14),
        cursorColor: const Color(0xFF6C63FF),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF1E1E38).withValues(alpha: 0.45),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF1E1E38).withValues(alpha: 0.45),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
