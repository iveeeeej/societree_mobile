import 'package:flutter/material.dart';

// DECLARE ENUM AT TOP LEVEL (outside the class)
enum AnnouncementType {
  event,
  cleaning,
  meeting,
  seminar,
  workshop,
  maintenance,
  urgent,
  important,
  other;

  factory AnnouncementType.fromString(String value) {
    try {
      return AnnouncementType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return AnnouncementType.other;
    }
  }
  
  // You can add helper methods to the enum
  IconData get icon {
    switch (this) {
      case AnnouncementType.event:
        return Icons.event;
      case AnnouncementType.cleaning:
        return Icons.cleaning_services;
      case AnnouncementType.meeting:
        return Icons.meeting_room;
      case AnnouncementType.seminar:
        return Icons.speaker_notes;
      case AnnouncementType.workshop:
        return Icons.build;
      case AnnouncementType.maintenance:
        return Icons.construction;
      case AnnouncementType.urgent:
        return Icons.priority_high;
      case AnnouncementType.important:
        return Icons.lightbulb;
      case AnnouncementType.other:
        return Icons.announcement;
    }
  }
  
  Color get color {
    switch (this) {
      case AnnouncementType.event:
        return Colors.orange;
      case AnnouncementType.cleaning:
        return Colors.brown;
      case AnnouncementType.meeting:
        return Colors.lightBlue;
      case AnnouncementType.seminar:
        return Colors.cyan;
      case AnnouncementType.workshop:
        return Colors.purple;
      case AnnouncementType.maintenance:
        return Colors.grey;
      case AnnouncementType.urgent:
        return Colors.red;
      case AnnouncementType.important:
        return Colors.amber;
      case AnnouncementType.other:
        return Colors.blueGrey;
    }
  }
}

class Announcement {
  final int id;
  final String title;
  final String content;
  final String? type; // <-- Keep as String for Option 2
  final DateTime dateTime;
  final bool isActive;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.type, // <-- String, not AnnouncementType
    required this.dateTime,
    this.isActive = true,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['announcement_datetime'] ?? DateTime.now().toString());
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Announcement(
      id: int.tryParse(json['announcement_id'].toString()) ?? 0,
      title: json['announcement_title']?.toString() ?? 'No Title',
      content: json['announcement_content']?.toString() ?? '',
      type: json['announcement_type']?.toString(), // <-- Just pass the string, don't convert to enum
      dateTime: parsedDate,
      isActive: json['is_active']?.toString() == '1' || 
                json['is_active'] == true || 
                json['is_active'] == 1,
    );
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? content,
    String? type, // <-- Change to String
    DateTime? dateTime,
    bool? isActive,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, type: $type, dateTime: $dateTime)';
  }

  // Helper methods - these will work with the String type
  IconData get icon {
    if (type == null) return Icons.announcement;
    try {
      final enumType = AnnouncementType.fromString(type!);
      return enumType.icon;
    } catch (e) {
      return Icons.announcement;
    }
  }

  Color get color {
    if (type == null) return Colors.blueGrey;
    try {
      final enumType = AnnouncementType.fromString(type!);
      return enumType.color;
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  // Keep the static methods for backward compatibility
  static IconData getIconForType(String? typeString) {
    if (typeString == null) return Icons.announcement;
    try {
      final type = AnnouncementType.fromString(typeString);
      return type.icon;
    } catch (e) {
      return Icons.announcement;
    }
  }

  static Color getColorForType(String? typeString) {
    if (typeString == null) return Colors.blueGrey;
    try {
      final type = AnnouncementType.fromString(typeString);
      return type.color;
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  // Date formatting methods remain the same...
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${_formatDateOnly(dateTime)} at ${_formatTime(dateTime)}';
    }
  }

  String get formattedDateFull {
    final day = _getDayOfWeek(dateTime.weekday);
    final month = _getMonth(dateTime.month);
    return '$day, $month ${dateTime.day}, ${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String get formattedDateShort {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hourStr:$minuteStr $amPm';
  }

  String _formatDateOnly(DateTime dateTime) {
    final month = _getMonth(dateTime.month, short: true);
    return '${month} ${dateTime.day}, ${dateTime.year}';
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  String _getMonth(int month, {bool short = false}) {
    switch (month) {
      case 1: return short ? 'Jan' : 'January';
      case 2: return short ? 'Feb' : 'February';
      case 3: return short ? 'Mar' : 'March';
      case 4: return short ? 'Apr' : 'April';
      case 5: return short ? 'May' : 'May';
      case 6: return short ? 'Jun' : 'June';
      case 7: return short ? 'Jul' : 'July';
      case 8: return short ? 'Aug' : 'August';
      case 9: return short ? 'Sep' : 'September';
      case 10: return short ? 'Oct' : 'October';
      case 11: return short ? 'Nov' : 'November';
      case 12: return short ? 'Dec' : 'December';
      default: return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'announcement_id': id,
      'announcement_title': title,
      'announcement_content': content,
      'announcement_type': type ?? '', // <-- Just the string
      'announcement_datetime': dateTime.toIso8601String(),
    };
  }
}