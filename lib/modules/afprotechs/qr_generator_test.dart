import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrGeneratorTestPage extends StatefulWidget {
  const QrGeneratorTestPage({super.key});

  @override
  State<QrGeneratorTestPage> createState() => _QrGeneratorTestPageState();
}

class _QrGeneratorTestPageState extends State<QrGeneratorTestPage> {
  final TextEditingController _studentIdController = TextEditingController();
  String _generatedQrData = '';

  // Sample student IDs from the database
  final List<String> _sampleStudentIds = [
    '2022309359',
    '2022310650', 
    '2023304604',
    '2023304615',
    '2023304652',
    '2023304665',
    '2023304673',
    '2023304700',
  ];

  void _generateQrData() {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a student ID')),
      );
      return;
    }

    setState(() {
      _generatedQrData = studentId; // Simple format: just the student ID
    });
  }

  void _copyToClipboard() {
    if (_generatedQrData.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedQrData));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR data copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator (Test)'),
        backgroundColor: const Color(0xFF000080),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generate QR Code Data for Testing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000080),
              ),
            ),
            const SizedBox(height: 20),
            
            // Student ID Input
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'Enter 10-digit student ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            
            // Generate Button
            ElevatedButton(
              onPressed: _generateQrData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000080),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Generate QR Data'),
            ),
            const SizedBox(height: 20),
            
            // Sample Student IDs
            const Text(
              'Sample Student IDs:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _sampleStudentIds.length,
                itemBuilder: (context, index) {
                  final studentId = _sampleStudentIds[index];
                  return Card(
                    child: ListTile(
                      title: Text(studentId),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          _studentIdController.text = studentId;
                        },
                      ),
                      onTap: () {
                        _studentIdController.text = studentId;
                        _generateQrData();
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Generated QR Data Display
            if (_generatedQrData.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated QR Data:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _generatedQrData,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy to Clipboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            const Text(
              'Instructions:\n'
              '1. Enter or select a student ID\n'
              '2. Generate QR data\n'
              '3. Use any QR code generator app to create a QR code with this data\n'
              '4. Test scanning with the attendance scanner',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }
}