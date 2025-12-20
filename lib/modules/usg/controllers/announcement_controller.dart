import 'package:get/get.dart';
import 'package:centralized_societree/modules/usg/model/announcement_model.dart';
import 'package:centralized_societree/services/api_service.dart';

class AnnouncementController extends GetxController {
  final ApiService apiService;
  
  // Reactive states
  final announcements = <Announcement>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  AnnouncementController(this.apiService);
  
  // Computed property for count
  int get announcementCount => announcements.length;
  
  // Get recent announcements (for dashboard preview)
  List<Announcement> get recentAnnouncements {
    return announcements.take(3).toList();
  }
  
  // Fetch announcements from API
  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await apiService.getAnnouncements();
      
      if (response['success'] == true) {
        final List<dynamic> data = response['announcements'] ?? [];
        
        // Clear existing announcements
        announcements.clear();
        
        // Add new announcements
        announcements.addAll(data.map((item) {
          return Announcement.fromJson(Map<String, dynamic>.from(item));
        }));
        
        // Sort by date (newest first)
        announcements.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load announcements';
        announcements.clear();
      }
    } catch (e) {
      errorMessage.value = 'Error fetching announcements: $e';
      announcements.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Refresh data
  Future<void> refresh() async {
    await fetchAnnouncements();
  }
}