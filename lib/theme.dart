import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- PALET WARNA (Sesuai Figma) ---
const kSoftBeige = Color(0xFFFFFBF5);   // Background
const kMainTeal = Color(0xFF5FA8A3);    // Primary
const kDarkGrey = Color(0xFF4A4A4A);    // Text Utama
const kAccentCoral = Color(0xFFF9A88E); // Aksen 1
const kAccentYellow = Color(0xFFFCDF8A); // Aksen 2
const kAccentPurple = Color(0xFFB399D4); // Aksen 3
const kIconGrey = Color(0xFFAAAAAA);    // Inaktif

ThemeData temanAsaTheme() {
  return ThemeData(
    primaryColor: kMainTeal,
    scaffoldBackgroundColor: kSoftBeige,
    
    // Font Dasar (Poppins)
    fontFamily: GoogleFonts.poppins().fontFamily,

    // --- APP BAR ---
    appBarTheme: AppBarTheme(
      backgroundColor: kSoftBeige,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: kDarkGrey),
      titleTextStyle: GoogleFonts.nerkoOne( // Judul App Bar pakai Nerko One
        color: kDarkGrey, 
        fontSize: 28, 
      ),
    ),

    // --- TEXT THEME ---
    textTheme: TextTheme(
      // Judul Besar (Start Screen)
      displayLarge: GoogleFonts.nerkoOne(
        fontSize: 48, 
        color: kMainTeal,
        height: 1.1,
      ),
      
      // Judul Halaman
      titleLarge: GoogleFonts.nerkoOne(
        fontSize: 32, 
        color: kDarkGrey,
      ),
      
      // Sub-judul / Judul Kartu
      titleMedium: GoogleFonts.nerkoOne(
        fontSize: 22, 
        color: kDarkGrey,
      ),
      
      // Teks Tombol / Label Bold
      titleSmall: GoogleFonts.poppins(
        fontSize: 14, 
        fontWeight: FontWeight.w600,
        color: kDarkGrey,
      ),
      
      // Teks Isi (Paragraf)
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16, 
        color: kDarkGrey,
      ),
      
      // Teks Keterangan (Kecil)
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14, 
        color: Colors.black54,
      ),
    ),

    // --- KARTU (CARD) ---
    cardTheme: CardTheme(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    // --- TOMBOL (BUTTONS) ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kMainTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kDarkGrey,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: kIconGrey, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),

    // --- INPUT TEXT ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.poppins(color: kIconGrey),
    ),
  );
}