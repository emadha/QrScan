import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenScan extends StatefulWidget {
  const ScreenScan({Key? key}) : super(key: key);

  @override
  State<ScreenScan> createState() => _ScreenScanState();
}

class _ScreenScanState extends State<ScreenScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Text(
              "Scan",
              style: GoogleFonts.poppins(fontSize: 42, color: Colors.white, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}
