import 'package:flutter/material.dart';
import 'package:centralized_societree/services/api_service.dart';
import 'package:centralized_societree/services/user_session.dart';
import 'package:centralized_societree/config/api_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ApiService _apiService;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: apiBaseUrl);
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final studentId = UserSession.studentId;
      
      if (studentId == null || studentId.isEmpty) {
        setState(() {
          _errorMessage = 'No student ID found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final response = await _apiService.getStudentProfile(studentId);
      
      if (response['success'] == true && response['student'] != null) {
        final student = response['student'] as Map<String, dynamic>;
        
        setState(() {
          _userData = {
            'name': _formatFullName(
              student['first_name'] ?? '',
              student['middle_name'] ?? '',
              student['last_name'] ?? '',
              student['full_name'] ?? '',
            ),
            'studentId': student['id_number']?.toString() ?? studentId,
            'course': student['course'] ?? 'N/A',
            'yearLevel': student['year']?.toString() ?? 'N/A',
            'section': student['section'] ?? 'N/A',
            'email': student['email'] ?? 'N/A',
            'contact': student['phone_number'] ?? 'N/A',
          };
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load profile data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatFullName(String firstName, String middleName, String lastName, String fullName) {
    if (fullName.isNotEmpty) return fullName;
    
    final nameParts = [
      firstName.trim(),
      if (middleName.trim().isNotEmpty) middleName.trim(),
      lastName.trim()
    ];
    return nameParts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null || _userData == null)
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'No profile data available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadStudentProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text(
                    _userData!['name'][0],
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // User Name
                Text(
                  _userData!['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Student ID
                Text(
                  'ID: ${_userData!['studentId']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User Details Section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Details Cards
          _buildDetailCard(
            icon: Icons.school,
            title: 'Academic Information',
            items: [
              {'label': 'Course', 'value': _userData!['course']},
              {'label': 'Year Level', 'value': _userData!['yearLevel']},
              {'label': 'Section', 'value': _userData!['section']},
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailCard(
            icon: Icons.contact_mail,
            title: 'Contact Information',
            items: [
              {'label': 'Email', 'value': _userData!['email']},
              {'label': 'Contact Number', 'value': _userData!['contact']},
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Refresh Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _loadStudentProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Card(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF383c83)),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['label']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item['value']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}