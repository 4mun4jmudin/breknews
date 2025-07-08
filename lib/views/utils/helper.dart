import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* Color Palette Profesional untuk Aplikasi Berita
Color cPrimary = const Color(
  0xFF0D47A1,
); // Biru tua (professional and trustworthy)
Color cAccent = const Color(0xFF1976D2); // Biru cerah (untuk interaksi)
Color cTextDark = const Color(0xFF212121); // Abu-abu sangat gelap (untuk judul)
Color cTextMedium = const Color(0xFF616161); // Abu-abu medium (untuk body text)
Color cBackground = const Color(0xFFFFFFFF); // Putih bersih
Color cLightGrey = const Color(
  0xFFF5F5F7,
); // Abu-abu terang (untuk card/divider)
Color cError = const Color(0xFFD32F2F); // Merah (konsisten)
Color cSuccess = const Color(0xFF388E3C); // Hijau (konsisten)

// Tetap menggunakan nama variabel lama untuk kompatibilitas, namun dengan nilai baru
Color cTextBlue = cTextMedium;
Color cLinear = cLightGrey;
Color cBlack = cTextDark;
Color cWhite = cBackground;
Color cGrey = cLightGrey;
Color cGreen = cSuccess;

//* Space
const Widget hsSuperTiny = SizedBox(width: 4.0);
const Widget hsTiny = SizedBox(width: 8.0);
const Widget hsSmall = SizedBox(width: 12.0);
const Widget hsMedium = SizedBox(width: 16.0);
const Widget hsLarge = SizedBox(width: 24.0);
const Widget hsXLarge = SizedBox(width: 36.0);
const Widget vsSuperTiny = SizedBox(height: 4.0);
const Widget vsTiny = SizedBox(height: 8.0);
const Widget vsSmall = SizedBox(height: 12.0);
const Widget vsMedium = SizedBox(height: 16.0);
const Widget vsLarge = SizedBox(height: 24.0);
const Widget vsXLarge = SizedBox(height: 36.0);

//* Divider
Widget spacedDivider = Column(
  children: <Widget>[
    vsTiny,
    Divider(color: cGrey, height: 1.0),
    vsTiny,
  ],
);

//* Screen
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

//* Font Weight
FontWeight thin = FontWeight.w100;
FontWeight extralight = FontWeight.w200;
FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
FontWeight extrabold = FontWeight.w800;

//* TextStyle (Menggunakan Poppins untuk kesan modern)
TextStyle headline1 = GoogleFonts.poppins(fontSize: 40, color: cTextDark);
TextStyle headline2 = GoogleFonts.poppins(fontSize: 34, color: cTextDark);
TextStyle headline3 = GoogleFonts.poppins(fontSize: 24, color: cTextDark);
TextStyle headline4 = GoogleFonts.poppins(fontSize: 20, color: cTextDark);
TextStyle subtitle1 = GoogleFonts.poppins(fontSize: 16, color: cTextDark);
TextStyle subtitle2 = GoogleFonts.poppins(fontSize: 14, color: cTextMedium);
TextStyle caption = GoogleFonts.poppins(fontSize: 12, color: cTextMedium);
TextStyle overline = GoogleFonts.poppins(fontSize: 10, color: cTextMedium);

//* Border (Desain lebih minimalis)
BorderSide defaultBorderSide = BorderSide(color: cGrey);
OutlineInputBorder enableBorder = OutlineInputBorder(
  borderSide: defaultBorderSide,
  borderRadius: BorderRadius.circular(8),
);
OutlineInputBorder focusedBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cPrimary, width: 1.5),
  borderRadius: BorderRadius.circular(8),
);
OutlineInputBorder errorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cError, width: 1.5),
  borderRadius: BorderRadius.circular(8),
);
OutlineInputBorder focusedErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cError, width: 1.5),
  borderRadius: BorderRadius.circular(8),
);
//* Box Decorations
BoxDecoration fieldDecortaion = BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: Colors.grey[200],
);
BoxDecoration disabledFieldDecortaion = BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: Colors.grey[100],
);
//* Field Variables
const double fieldHeight = 55;
const double smallFieldHeight = 40;
const double inputFieldBottomMargin = 30;
const double inputFieldSmallBottomMargin = 0;
const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 15);
const EdgeInsets largeFieldPadding = EdgeInsets.symmetric(
  horizontal: 15,
  vertical: 15,
);
