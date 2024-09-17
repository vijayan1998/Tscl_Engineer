// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/customer.dart';
import 'package:trichy_iccc_engineer/User%20preferences/user_prefernces.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';

class GrievanceController extends GetxController {
  
 
  var isLoading = true.obs;
//  final CustomerCurrentUser _customerController =
//       Get.put(CustomerCurrentUser());
  var userModel = CustomerModel().obs;
  @override
  void onInit() {
    fetchUserData();
    super.onInit();
  }
  Future<void> fetchUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
   final userid = prefs.getString('userId');
  //final customer = _customerController.customer;
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
        CustomerModel customerInfo = CustomerModel.fromJson(jsonData);
        await RememberUserPrefs.saveRememberUser(customerInfo);
         userModel.value = CustomerModel.fromJson(jsonData);
          print('Stored Customer Data: ${customerInfo.toJson()}');
        print('User data successfully fetched and saved.');
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

Future editprofile(BuildContext context,String userid,String username,String address,String pincode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    var body = {
      "user_name":username,
      "address":address,
      "pincode":pincode,
    };
   
    var response = await http.post(
      Uri.parse(ApiUrl.editprof(userid)), 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Update profile successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      //  userController.fetchUserData();
       Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen, (route)=>false);
      // Navigate to another screen or refresh the current screen
    } else {
      Fluttertoast.showToast(
        msg: "Failed to Update Profile",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  
}
