import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0, end: 220).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showQuickFeedback(BuildContext context) async {
    HapticFeedback.mediumImpact(); // Safe vibration
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code Detected!'),
        duration: Duration(milliseconds: 800),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onDetect(BuildContext context, BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    
    // Just show quick feedback without processing
    await _showQuickFeedback(context);
    debugPrint("QR Code detected: $code");
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = MobileScannerController();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Attendance Scanner",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF000080), // navy blue
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<TorchState>(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                if (state == TorchState.on) {
                  return const Icon(Icons.flashlight_on);
                } else {
                  return const Icon(Icons.flashlight_off);
                }
              },
            ),
            onPressed: () {
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) => _onDetect(context, capture),
          ),
          // Instructional overlays at the top (QR icon + text)
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code,
                  size: 54,
                  color: Colors.white,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Position QR Code Inside Frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                const Text(
                  'Hold steady for scanning',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Scanner Overlay (frame & animated scan bar)
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  // Frame
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8), 
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Animated scan bar
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: 10,
                        right: 10,
                        top: _scanAnimation.value,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.35),
                                blurRadius: 2,
                                spreadRadius: 0.5,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}