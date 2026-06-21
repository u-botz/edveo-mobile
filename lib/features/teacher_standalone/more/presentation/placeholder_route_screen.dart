import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceholderRouteScreen extends StatelessWidget {
  final String title;

  const PlaceholderRouteScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
