import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> 
    with SingleTickerProviderStateMixin { // ADD THIS MIXIN
  
  String? qrCode;
  bool _isScanning = true;
  bool _isProcessing = false;
  DateTime? _lastScannedTime;
  
  // ADD: Animation controller for scanning line
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  
  // Constants for better maintainability
  static const double scannerBoxSize = 280.0;
  static const Duration scanCooldown = Duration(milliseconds: 500);
  static const Duration restartDelay = Duration(milliseconds: 300);
  static const Duration feedbackDuration = Duration(milliseconds: 500);
  static const Color scannerColor = Color(0xFF2196F3);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFf9a702);
  
  // ADD: Performance optimization variables
  final _scanningDebouncer = _Debouncer(milliseconds: 300);
  Timer? _cameraRestartTimer;
  
  // Optimize controller with better settings
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 100,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
    returnImage: false,
  );

  // ADD: Initialize camera with better settings
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true); // Continuous up-down motion
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start camera immediately with optimized settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCamera();
    });
  }

  // ADD: Method to start camera with error handling
  Future<void> _startCamera() async {
    try {
      // Check camera permission
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            _showPermissionError();
          }
          return;
        }
      }
      
      await _cameraController.start();
      setState(() {
        _isScanning = true;
      });
      
      // Start scanning animation
      _scanAnimationController.repeat(reverse: true);
      
    } catch (e) {
      print("Camera start error: $e");
      if (mounted) {
        _showCameraError();
      }
    }
  }

  // ADD: Show permission error
  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Camera permission is required to scan QR codes'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  // ADD: Show camera error
  void _showCameraError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to start camera. Please try again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    // Use debouncer to prevent rapid successive calls
    _scanningDebouncer.run(() async {
      // Prevent multiple simultaneous processing
      if (_isProcessing || !_isScanning) return;
      
      // Anti-shake/throttling: prevent scanning same code too frequently
      final now = DateTime.now();
      if (_lastScannedTime != null && 
          now.difference(_lastScannedTime!) < scanCooldown) {
        return;
      }
      
      if (capture.barcodes.isEmpty) return;
      
      final Barcode barcode = capture.barcodes.first;
      final String? rawValue = barcode.rawValue;
      
      if (rawValue == null || rawValue.isEmpty) return;
      
      // Validate QR code format
      if (!_isValidQR(rawValue)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid QR code format'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          _restartCamera();
        }
        return;
      }
      
      // Prevent duplicate scanning of same code
      if (qrCode == rawValue) return;
      
      // ADD: Temporarily pause scanning for better UX
      _cameraController.stop();
      
      // Stop scanning animation
      _scanAnimationController.stop();
      
      setState(() {
        _isProcessing = true;
        qrCode = rawValue;
        _lastScannedTime = now;
        _isScanning = false;
      });
      
      // ADD: Log the scan
      _logScan(rawValue);
      
      // ADD: Show immediate visual and haptic feedback
      await _showQuickFeedback();
      
      // ADD: Short delay for better user experience
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Show result dialog
      if (mounted) {
        await _showResultDialog(rawValue);
        
        // ADD: Restart camera after dialog is closed
        _restartCamera();
      }
    });
  }

  // ADD: Validate QR code
  bool _isValidQR(String code) {
    // Add your specific validation logic here
    // Example: Check if it's a valid URL, JSON, or specific format
    return code.isNotEmpty && code.length > 3;
  }

  // ADD: Log scan event
  void _logScan(String qrCode) {
    final timestamp = DateTime.now().toIso8601String();
    final truncatedCode = qrCode.length > 20 
      ? '${qrCode.substring(0, min(20, qrCode.length))}...' 
      : qrCode;
    
    print('QR Scan Event - Time: $timestamp, Code: $truncatedCode');
    
    // You could also send to analytics service here
    // Analytics.logEvent('qr_scan', {'code_length': qrCode.length});
  }

  // ADD: Show result dialog
  Future<void> _showResultDialog(String rawValue) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Successfully Signed In',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'QR Code Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    rawValue,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 40),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ADD: Method to restart camera after processing
  void _restartCamera() {
    _cameraRestartTimer?.cancel();
    _cameraRestartTimer = Timer(restartDelay, () {
      if (mounted && !_isScanning) {
        _cameraController.start();
        setState(() {
          _isProcessing = false;
          _isScanning = true;
        });
        
        // Restart scanning animation
        _scanAnimationController.repeat(reverse: true);
      }
    });
  }

  // ADD: Quick visual feedback method with vibration
  Future<void> _showQuickFeedback() async {
    // Haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 100);
    }
    
    // Quick visual indicator
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR Code Detected!'),
        duration: feedbackDuration,
        backgroundColor: successColor,
      ),
    );
  }

  @override
  void dispose() {
    // ADD: Clean up animation controller
    _scanAnimationController.dispose();
    
    // Clean up timers
    _scanningDebouncer.dispose();
    _cameraRestartTimer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Control animation based on scanning state
    if (_isScanning && !_isProcessing && !_scanAnimationController.isAnimating) {
      _scanAnimationController.repeat(reverse: true);
    } else if ((!_isScanning || _isProcessing) && _scanAnimationController.isAnimating) {
      _scanAnimationController.stop();
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1e174a),
        foregroundColor: Colors.white,
        title: Text(
          'Attendance Scanner',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _cameraController.switchCamera(),
            tooltip: 'Switch Camera',
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => _cameraController.toggleTorch(),
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner with optimized settings
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          
          // Semi-transparent overlay with gradient for better visibility
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          
          // Scanner Box with optimized frame
          Center(
            child: Container(
              width: scannerBoxSize,
              height: scannerBoxSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isScanning 
                    ? Colors.white.withOpacity(0.5) 
                    : scannerColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),
                ],
              ),
            ),
          ),
          
          // Instructions text
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner, 
                  color: _isScanning 
                    ? (_isProcessing ? Colors.amber : Colors.white) 
                    : Colors.grey,
                  size: 50,
                ),
                const SizedBox(height: 20),
                Text(
                  _isScanning 
                    ? (_isProcessing ? 'Processing QR Code...' : 'Position QR Code Inside Frame')
                    : 'Processing...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _isScanning
                    ? (_isProcessing ? 'Please wait...' : 'Hold steady for automatic scanning')
                    : 'Scanning completed',
                  style: TextStyle(
                    color: _isScanning 
                      ? (_isProcessing ? Colors.amber : Colors.white70) 
                      : Colors.green,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Bottom status bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    qrCode == null
                        ? 'Ready to scan'
                        : 'Scanned: ${qrCode!.length > 30 ? '${qrCode!.substring(0, 30)}...' : qrCode!}',
                    style: TextStyle(
                      color: _isProcessing ? Colors.white : successColor,
                      fontWeight: _isProcessing ? FontWeight.bold : FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
          
          // Optimized scanning line
          if (_isScanning && !_isProcessing) _buildScanningLine(),
          
          // ADD: Processing overlay when scanning
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Processing QR Code...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ), 
            ),
        ],
      ),
    );
  }

  // Simplified corner widget for better performance
  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
                  ? (_isProcessing ? Colors.grey : accentColor)
                  : Colors.transparent,
              width: 4,
            ),
            top: BorderSide(
              color: (alignment == Alignment.topLeft || alignment == Alignment.topRight)
                  ? (_isProcessing ? Colors.grey : accentColor)
                  : Colors.transparent,
              width: 4,
            ),
            right: BorderSide(
              color: (alignment == Alignment.topRight || alignment == Alignment.bottomRight)
                  ? (_isProcessing ? Colors.grey : accentColor)
                  : Colors.transparent,
              width: 4,
            ),
            bottom: BorderSide(
              color: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight)
                  ? (_isProcessing ? Colors.grey : accentColor)
                  : Colors.transparent,
              width: 4,
            ),
          ),
        ),
      ),
    );
  }

  // Optimized scanning line with AnimationController
  Widget _buildScanningLine() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 240,
        height: 280,
        child: AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ScanLinePainter(_scanAnimation.value),
            );
          },
        ),
      ),
    );
  }
}

// Custom painter for scanning line
class _ScanLinePainter extends CustomPainter {
  final double animationValue;

  _ScanLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height * animationValue;
    
    // Create a gradient effect for the scanning line
    final gradient = LinearGradient(
      colors: [
        Colors.blue.withOpacity(0.7),
        Colors.blue.withOpacity(0.7),
        Colors.blue.withOpacity(0.7),
        Colors.blue.withOpacity(0.7),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, lineY, size.width, 4))
      ..style = PaintingStyle.fill;
    
    // Draw the main scanning line
    canvas.drawRect(
      Rect.fromLTWH(0, lineY, size.width, 2),
      paint,
    );
    
    // Draw a glow effect
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, lineY, size.width, 2),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// ADD: Debouncer class for performance optimization
class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}