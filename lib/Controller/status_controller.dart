import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/status.dart';

class StatusController extends GetxController{

//final CustomerCurrentUser customerController = Get.put(CustomerCurrentUser());

Future<List<StatusModel>> getAllStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse(ApiUrl.status),
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

        return decryptedJsonList.map((item) => StatusModel.fromJson(item)).toList();
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
}