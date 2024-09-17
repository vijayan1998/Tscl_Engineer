import 'package:flutter/material.dart';

class StatusModel {
  final String statusid;
  final String statusname;
  final Color color;         // Updated to Color type
  final String createbyuser;

  StatusModel({
    required this.statusid,
    required this.statusname,
    required this.color,
    required this.createbyuser,
  });

  // Factory method to create an instance from JSON
  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      statusid: json['status_id'],
      statusname: json['status_name'],
      color: _parseColor(json['color']), // Parse color from the hex string
      createbyuser: json['created_by_user'],
    );
  }

  // Utility method to convert hex string to Color
  static Color _parseColor(String hexColor) {
    // Remove leading "#" if present
    hexColor = hexColor.replaceAll("#", "");
    
    // If the string length is 6 (e.g., "14532d"), add "FF" for full opacity
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    // Convert the hex string to an integer and create a Color object
    return Color(int.parse(hexColor, radix: 16));
  }
}
