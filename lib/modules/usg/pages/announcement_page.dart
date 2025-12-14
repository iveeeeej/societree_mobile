import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'package:centralized_societree/modules/usg/model/announcement_model.dart';

class AnnouncementPage extends StatefulWidget {
  final ApiService apiService;
  
  const AnnouncementPage({
    super.key,
    required this.apiService,
  });

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  List<Announcement> _announcements = [];
  List<Announcement> _filteredAnnouncements = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasError = false;
  TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final announcements = await widget.apiService.getAnnouncementsList();
      
      // Validate announcements list
      if (announcements is! List) {
        throw Exception('Invalid response format from server');
      }
      
      // Sort by date (newest first)
      announcements.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        _announcements = announcements;
        _filteredAnnouncements = announcements;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAnnouncements(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAnnouncements = _announcements;
      } else {
        _filteredAnnouncements = _announcements
            .where((announcement) =>
                announcement.title.toLowerCase().contains(query.toLowerCase()) ||
                announcement.content.toLowerCase().contains(query.toLowerCase()) ||
                (announcement.type ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _filteredAnnouncements = _announcements;
      }
    });
  }

  void _showAnnouncementDetails(BuildContext context, Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Announcement.getColorForType(announcement.type),
                                child: Icon(
                                  Announcement.getIconForType(announcement.type),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      announcement.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      announcement.formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Content
                          Text(
                            announcement.content,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Type badge
                          if (announcement.type != null && announcement.type!.isNotEmpty) ...[
                            const Divider(),
                            Row(
                              children: [
                                Icon(
                                  Announcement.getIconForType(announcement.type),
                                  color: Announcement.getColorForType(announcement.type),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Type: ${announcement.type!.toUpperCase()}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          const SizedBox(height: 8),
                          Text(
                            'Posted: ${announcement.formattedDateFull}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementItem(BuildContext context, Announcement announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAnnouncementDetails(context, announcement),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Announcement.getColorForType(announcement.type),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Announcement.getIconForType(announcement.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          announcement.formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Preview content
                    Text(
                      announcement.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    
                    // Type badge
                    if (announcement.type != null && announcement.type!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Announcement.getColorForType(announcement.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Announcement.getIconForType(announcement.type),
                              size: 12,
                              color: Announcement.getColorForType(announcement.type),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              announcement.type!.toUpperCase(),
                              style: TextStyle(
                                color: Announcement.getColorForType(announcement.type),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Forward arrow
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to Load Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAnnouncements,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No Announcements Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Check back later',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAnnouncements,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        onChanged: _filterAnnouncements,
        decoration: InputDecoration(
          hintText: 'Search Announcements...',
          hintStyle: TextStyle(color: Color(0xFF9D9D9D)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9D9D9D)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF9D9D9D)),
            onPressed: _toggleSearchBar,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Color(0xFFEEEDF3),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      color: Colors.blue,
      child: _filteredAnnouncements.isEmpty && _searchController.text.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Results Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Try different search terms',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _filteredAnnouncements.length,
              itemBuilder: (context, index) {
                return _buildAnnouncementItem(context, _filteredAnnouncements[index]);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : _announcements.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        if (_showSearchBar) _buildSearchBar(),
                        Expanded(
                          child: _buildAnnouncementsList(),
                        ),
                      ],
                    ),
      floatingActionButton: _announcements.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search FAB (only show when search bar is not visible)
                if (!_showSearchBar)
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: FloatingActionButton.small(
                      onPressed: _toggleSearchBar,
                      heroTag: 'search_fab',
                      foregroundColor: Color(0xFF1A1A34),
                      backgroundColor: Color(0xFFDEE0FD),
                      child: const Icon(Icons.search),
                      tooltip: 'Search',
                    ),
                  ),
                const SizedBox(width: 8),
                // Refresh FAB (always show when there are announcements)
                SizedBox(
                  height: 60,
                  width: 60,
                  child: FloatingActionButton.small(
                    onPressed: _loadAnnouncements,
                    heroTag: 'refresh_fab',
                    foregroundColor: Color(0xFF1A1A34),
                    backgroundColor: Color(0xFFDEE0FD),
                    child: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ),
              ],
            )
          : null,
    );
  }
}