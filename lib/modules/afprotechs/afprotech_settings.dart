import 'package:flutter/material.dart';
import 'afprotech_terms.dart';

class AfprotechSettingsScreen extends StatefulWidget {
  const AfprotechSettingsScreen({super.key});

  @override
  State<AfprotechSettingsScreen> createState() => _AfprotechSettingsScreenState();
}

class _AfprotechSettingsScreenState extends State<AfprotechSettingsScreen> {
  final Color navyBlue = const Color(0xFF000080);
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    Color scaffoldBg = isDarkMode ? Colors.black : Colors.white;
    Color mainColor = isDarkMode ? Colors.white : navyBlue;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTermsConditionsContainer(textColor, mainColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsConditionsContainer(Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description,
            color: mainColor,
            size: 24,
          ),
        ),
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          "View Terms of Service",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AfprotechTermsScreen(),
            ),
          );
        },
      ),
    );
  }



}