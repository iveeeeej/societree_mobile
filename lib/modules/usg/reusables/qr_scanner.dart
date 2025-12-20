import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> 
    with SingleTickerProviderStateMixin {
  
  String? qrCode;
  bool _isScanning = true;
  bool _isProcessing = false;
  DateTime? _lastScannedTime;
  
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  
  static const double scannerBoxSize = 280.0;
  static const Duration scanCooldown = Duration(milliseconds: 500);
  static const Duration restartDelay = Duration(milliseconds: 300);
  static const Duration feedbackDuration = Duration(milliseconds: 500);
  static const Color scannerColor = Color(0xFF2196F3);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFf9a702);
  
  final _scanningDebouncer = _Debouncer(milliseconds: 300);
  Timer? _cameraRestartTimer;
  
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 1000,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
    returnImage: false,
  );

  @override
  void initState() {
    super.initState();
    
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCamera();
    });
  }

  Future<void> _startCamera() async {
    try {
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
      
      _scanAnimationController.repeat(reverse: true);
      
    } catch (e) {
      print("Camera start error: $e");
      if (mounted) {
        _showCameraError();
      }
    }
  }

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
    _scanningDebouncer.run(() async {
      if (_isProcessing || !_isScanning) return;
      
      final now = DateTime.now();
      if (_lastScannedTime != null && 
          now.difference(_lastScannedTime!) < scanCooldown) {
        return;
      }
      
      if (capture.barcodes.isEmpty) return;
      
      final Barcode barcode = capture.barcodes.first;
      final String? rawValue = barcode.rawValue;
      
      if (rawValue == null || rawValue.isEmpty) return;
      
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
      
      if (qrCode == rawValue) return;
      
      _cameraController.stop();
      _scanAnimationController.stop();
      
      setState(() {
        _isProcessing = true;
        qrCode = rawValue;
        _lastScannedTime = now;
        _isScanning = false;
      });
      
      _logScan(rawValue);
      await _showQuickFeedback();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await _processAndSaveQRData(rawValue);
    });
  }

  bool _isValidQR(String code) {
    if (code.isEmpty) return false;
    
    final cleanedCode = code.replaceAll('\n', ' ')
                            .replaceAll('\r', ' ')
                            .replaceAll('\t', ' ')
                            .replaceAll(RegExp(r'\s+'), ' ')
                            .trim();
    
    final parts = cleanedCode.split(' ').where((p) => p.isNotEmpty).toList();
    
    final isValid = parts.length >= 4;
    
    return isValid;
  }

  void _logScan(String qrCode) {
    final timestamp = DateTime.now().toIso8601String();
    final truncatedCode = qrCode.length > 20 
      ? '${qrCode.substring(0, min(20, qrCode.length))}...' 
      : qrCode;
    
    print('QR Scan Event - Time: $timestamp, Code: $truncatedCode');
  }

  Map<String, String>? _parseQRData(String qrData) {
    try {
      String cleanedData = qrData.replaceAll('\n', ' ')
                                 .replaceAll('\r', ' ')
                                 .replaceAll('\t', ' ')
                                 .replaceAll(RegExp(r'\s+'), ' ')
                                 .trim();
      
      final parts = cleanedData.split(' ').where((part) => part.isNotEmpty).toList();
      
      if (parts.length < 4) {
        return null;
      }
      
      String? idNumber;
      int idIndex = -1;
      
      for (int i = 0; i < parts.length; i++) {
        if (RegExp(r'^\d+$').hasMatch(parts[i])) {
          idNumber = parts[i];
          idIndex = i;
          break;
        }
      }
      
      if (idNumber == null || idIndex < 2) {
        return null;
      }
      
      final firstName = parts[0];
      String lastName = parts[idIndex - 1];
      
      if (lastName.contains('.')) {
        final dotIndex = lastName.indexOf('.');
        lastName = lastName.substring(dotIndex + 1);
      }
      
      final course = parts.sublist(idIndex + 1).join(' ');
      final fullName = "$firstName $lastName";
      
      return {
        'first_name': firstName,
        'last_name': lastName,
        'id_number': idNumber,
        'course': course,
        'name': fullName,
      };
      
    } catch (e) {
      print("Error parsing QR data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> _checkStudentExists(String idNumber) async {
    try {
      final apiUrl = apiBaseUrl;
      
      final response = await http.post(
        Uri.parse('$apiUrl/usg_check_student.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_number': idNumber}),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['student'];
        }
      }
      return null;
    } catch (e) {
      print("Error checking student: $e");
      return null;
    }
  }

  Future<bool> _saveToAttendance(Map<String, dynamic> studentInfo) async {
    try {
      final apiUrl = apiBaseUrl;
      
      final response = await http.post(
        Uri.parse('$apiUrl/usg_save_attendance.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_number': studentInfo['id_number'],
          'first_name': studentInfo['first_name'] ?? '',
          'last_name': studentInfo['last_name'] ?? '',
          'course': studentInfo['course'] ?? '',
          'year': studentInfo['year'] ?? '',
          'section': studentInfo['section'] ?? '',
          'role': studentInfo['role'] ?? 'student',
        }),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error saving attendance: $e");
      return false;
    }
  }

  Future<void> _processAndSaveQRData(String qrData) async {
    try {
      final parsedData = _parseQRData(qrData);
      
      if (parsedData == null) {
        if (mounted) {
          await _showResultDialog(
            isSuccess: false,
            message: 'Invalid QR format',
            details: 'Could not parse QR data.\n\nReceived: $qrData',
          );
        }
        _restartCamera();
        return;
      }
      
      final studentId = parsedData['id_number']!;
      
      final studentInfo = await _checkStudentExists(studentId);
      
      if (studentInfo == null) {
        if (mounted) {
          await _showResultDialog(
            isSuccess: false,
            message: 'Student not found',
            details: 'ID: $studentId\nMake sure the student is registered.',
          );
        }
        _restartCamera();
        return;
      }
      
      final saveResult = await _saveToAttendance(studentInfo);
      
      if (mounted) {
        await _showResultDialog(
          isSuccess: saveResult,
          message: saveResult 
              ? 'Attendance Recorded!' 
              : 'Failed to record',
          details: saveResult 
              ? '${parsedData['name']}\nID: $studentId\nCourse: ${parsedData['course']}'
              : 'ID already recorded',
        );
      }
      
    } catch (e) {
      print("Error processing QR: $e");
      if (mounted) {
        await _showResultDialog(
          isSuccess: false,
          message: 'Error processing QR',
          details: e.toString(),
        );
      }
      _restartCamera();
    }
  }

  Future<void> _showResultDialog({
    required bool isSuccess,
    required String message,
    required String details,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 60,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    details,
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
                if (isSuccess) {
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: isSuccess ? Colors.grey : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 40),
              ),
              child: Text(isSuccess ? 'Done' : 'Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _restartCamera() {
    _cameraRestartTimer?.cancel();
    _cameraRestartTimer = Timer(restartDelay, () {
      if (mounted && !_isScanning) {
        _cameraController.start();
        setState(() {
          _isProcessing = false;
          _isScanning = true;
        });
        
        _scanAnimationController.repeat(reverse: true);
      }
    });
  }

  Future<void> _showQuickFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 100);
    }
    
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
    _scanAnimationController.dispose();
    _scanningDebouncer.dispose();
    _cameraRestartTimer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          
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
                    'Ready to scan student QR',
                    style: TextStyle(
                      color: _isProcessing ? Colors.white : successColor,
                      fontWeight: _isProcessing ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          
          if (_isScanning && !_isProcessing) _buildScanningLine(),
          
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

class _ScanLinePainter extends CustomPainter {
  final double animationValue;

  _ScanLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height * animationValue;
    
    final gradient = LinearGradient(
      colors: [
        Colors.blue.withOpacity(0.8),
        Colors.blue.withOpacity(0.8),
        Colors.blue.withOpacity(0.8),
        Colors.blue.withOpacity(0.8),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, lineY, size.width, 4))
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, lineY, size.width, 2.5),
      paint,
    );
    
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