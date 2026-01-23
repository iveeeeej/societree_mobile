import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            print('Barcode found! ${barcode.rawValue}');
          }
          if (image != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF8bc53f),
                title: Center(
                  child: Text(
                    'Welcome!',
                    style: GoogleFonts.oswald(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ),
            );

            Future.delayed(const Duration(milliseconds: 800), () {
              if (!context.mounted) return;

              Navigator.pop(context); // close dialog
              Navigator.pushNamed(context, '/dashboard');
            });
          }

        },
      ),
    );
  }
}