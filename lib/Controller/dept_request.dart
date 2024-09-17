import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/customer.dart';
import 'package:trichy_iccc_engineer/Model/dept_model.dart';

class DeptController extends GetxController{

//final CustomerCurrentUser customerController = Get.put(CustomerCurrentUser());

Future<List<DeptModel>> getAllDept() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse(ApiUrl.depart),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

        return decryptedJsonList.map((item) => DeptModel.fromJson(item)).toList();
      } catch (e) {
        throw Exception('Decryption failed: $e');
      }
    } else {
      throw Exception('Failed to load complaint types');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<List<CustomerModel>> fetchUserData1() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  final userid = prefs.getString('userId');
  
  try {
    final response = await http.get(
      Uri.parse(ApiUrl.getuserid(userid!)),
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
        // Convert the decrypted data to JSON
        var jsonData = jsonDecode(decryptedData);

        // Check if jsonData is a list or a single object
        if (jsonData is List) {
          // If it's a list, convert it to a list of CustomerModel
          List<CustomerModel> customerInfoList = jsonData.map((item) => CustomerModel.fromJson(item)).toList();
          return customerInfoList;
        } else if (jsonData is Map<String, dynamic>) {
          // If it's a single object, convert it to a CustomerModel and return as a list with one item
          return [CustomerModel.fromJson(jsonData)];
        } else {
          debugPrint('Unexpected JSON format');
          return []; // Return an empty list in case of unexpected format
        }
      } catch (e) {
        debugPrint('Decryption or JSON parsing failed: $e');
        return []; // Return an empty list in case of failure
      }
    } else {
      debugPrint('Failed to fetch user data: ${response.statusCode}');
      return []; // Return an empty list in case of failure
    }
  } catch (e) {
    debugPrint('HTTP request failed: $e');
    return []; // Return an empty list in case of failure
  }
}


}