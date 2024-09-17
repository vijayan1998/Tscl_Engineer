import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:trichy_iccc_engineer/Model/api_url.dart';

class UserService {
  int? itemEscalationCount;

  // Method to fetch user data and escalation count
  Future<void> fetchAndCountEscalations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userId = prefs.getString('userId');

    try {
      // First API call to fetch user data
      final response = await http.get(
        Uri.parse(ApiUrl.getuserid(userId!)),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        // Decryption key and IV
        final key = encrypt.Key.fromBase16('9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
        final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
        final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

        try {
          // Decrypt the encrypted data
          final encryptedData = encrypt.Encrypted.fromBase16(json['data']);
          final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
          var jsonData = jsonDecode(decryptedData);

          // Extract dept_name and role
          final deptName = jsonData['dept_name'];
          final role = jsonData['role'];

          // Proceed to the second API call
          await _fetchEscalationCount(deptName, role, token!);

        } catch (e) {
          print('Decryption or JSON parsing failed: $e');
        }

      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP request failed: $e');
    }
  }

  // Private method to fetch escalation count
  Future<void> _fetchEscalationCount(String deptName, String role, String token) async {
    try {
      final queryParams = {
        'escalation_department': deptName,
        'escalation_to': role,
      };

      final url = Uri.parse(ApiUrl.escalation).replace(queryParameters: queryParams);
      debugPrint('Fetching complaint data from URL: $url');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Decryption key and IV
        final key = encrypt.Key.fromBase16('9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
        final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
        final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

        try {
          // Decrypt the encrypted data
          final encryptedData = encrypt.Encrypted.fromBase16(jsonResponse['data']);
          final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
          final decryptedJson = jsonDecode(decryptedData);
          debugPrint('Decrypted data: $decryptedData');
          debugPrint('Decrypted JSON: $decryptedJson');

          // Count items based on data type
          if (decryptedJson is List) {
            itemEscalationCount = decryptedJson.length;
          } else if (decryptedJson is Map) {
            itemEscalationCount = 1; // Map contains a single item
          } else {
            itemEscalationCount = 0; // Handle unexpected data type
          }

          debugPrint('Item count: $itemEscalationCount');

        } catch (e) {
          debugPrint('Decryption failed: $e');
        }

      } else {
        debugPrint('Failed to fetch complaint data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP request failed: $e');
    }
  }

  // Method to get item count
  int? getItemEscalationCount() {
    return itemEscalationCount;
  }
}
