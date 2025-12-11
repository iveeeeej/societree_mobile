import 'package:flutter/material.dart';

class AfprotechTermsScreen extends StatelessWidget {
  const AfprotechTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color navyBlue = Color(0xFF000080);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'AFPROTECH Terms & Conditions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: navyBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Agreement to Terms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'By using AFPROTECH services through this application, you agree to comply with and be bound by the following terms and conditions:',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'User Responsibilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• Use the platform responsibly and respectfully\n• Follow all university policies and guidelines\n• Provide accurate information for verification\n• Respect the decisions and rules set by AFPROTECH\n• Report any issues or violations to administrators',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Privacy & Data Protection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your student information is processed solely for providing AFPROTECH services. Data is protected according to university privacy policies and will not be shared with unauthorized third parties.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Code of Conduct',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Harassment, misconduct, and platform abuse are strictly prohibited. Violations may lead to sanctions under university policies including suspension of access to AFPROTECH services.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Service Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'AFPROTECH services are provided as-is and may be subject to maintenance, updates, or temporary unavailability. We strive to maintain consistent service but cannot guarantee 100% uptime.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'For questions about these terms or AFPROTECH services, please contact the organization through official university channels.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  
                  Center(
                    child: Text(
                      'Last updated: December 2024',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}