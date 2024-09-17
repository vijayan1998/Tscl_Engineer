
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/customer.dart';

Future<CustomerModel> fetchUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  final userId = prefs.getString('userId'); // Assuming userId is stored in prefs

  if (userId == null || token == null) {
    throw Exception('User ID or token is missing');
  }

  final response = await http.get(
    Uri.parse(ApiUrl.getuserid(userId)),
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
      print('Decrypted Data: $decryptedData');

      // Convert the decrypted data to JSON
      var jsonData = jsonDecode(decryptedData);
      return CustomerModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Decryption or JSON parsing failed: $e');
    }
  } else {
    throw Exception('Failed to fetch user data: ${response.statusCode}');
  }
}
