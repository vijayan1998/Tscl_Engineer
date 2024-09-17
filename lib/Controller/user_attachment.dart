import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:trichy_iccc_engineer/Model/attachment_model.dart';

class UserImageController extends GetxController{
  var imageBytesList = <Uint8List>[].obs;
   List<AttachmentLog> logDetails = [];

  Future<void> fetchAndDisplayImage(String attachmentId) async {
    final url = ApiUrl.grievanceWorksheet(attachmentId);
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String? contentType = response.headers['content-type'];

        if (contentType == null || contentType == 'undefined') {
          contentType = 'image/jpeg'; 
        }

        if (contentType.startsWith('image/')) {
          // Clear existing image list and add new image bytes
          imageBytesList.clear();
          imageBytesList.add(response.bodyBytes);
          // Trigger rebuild
        } else {
          debugPrint('Unexpected content-type: $contentType');
        }
      } else {
        debugPrint('Failed to load image, status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Image fetch failed: $e');
    }
  }

  Future<void> fetchLogAttachment(String grievanceId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  try {
    final url = ApiUrl.grievanceattchment(grievanceId); // Replace with your API URL
    debugPrint('Fetching log details from URL: $url');

    final response = await http.get(
      Uri.parse(url),
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
        List<dynamic> decryptedJsonList = jsonDecode(decryptedData);
       // debugPrint('Decrypted log data: $decryptedData');

       
          logDetails = decryptedJsonList.map((item) {
            return AttachmentLog.fromJson(item); // Use the factory constructor
          }).toList();

           logDetails.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
     

      } catch (e) {
        debugPrint('Decryption failed: $e');
      }

    } else {
      debugPrint('Failed to fetch log data: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('HTTP request failed: $e');
  }
}
}