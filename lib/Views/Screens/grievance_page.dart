import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';
import 'package:trichy_iccc_engineer/Views/Screens/allitem.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:trichy_iccc_engineer/color.dart';

class GrievancePage extends StatefulWidget {
  const GrievancePage({super.key});

  @override
  State<GrievancePage> createState() => _GrievancePageState();
}


class _GrievancePageState extends State<GrievancePage> {
  late List<String> complaintTypes = [];

  int _selectedTabIndex = 0;
  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

 Future<void> fetchUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  try {
    final url = ApiUrl.complainttype;
    debugPrint('Fetching user data from URL: $url');

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

        setState(() {
          complaintTypes = decryptedJsonList.map((item) => item['complaint_type'].toString()).toList();
        });

      } catch (e) {
        debugPrint('Decryption failed: $e');
      }

    } else {
      debugPrint('Failed to fetch user data: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('HTTP request failed: $e');
  }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
       appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(onPressed: (){
               Navigator.pushNamed(context, AppPageNames.homeScreen);
            }, 
            icon:const Icon(Icons.arrow_back,color: Colors.black,)),
            title: const Text('Grievance List',style:  TextStyle(fontWeight: FontWeight.w500),),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)]),
                height: 0.8,
              ),
            ),
          ),
      body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                const SizedBox(height: 10,),
                       _buildTabContent(),
                ],
              ),
            ),
          ),
           );
        }

 Widget _buildTabContent() {
  if (complaintTypes.isEmpty) {
    return const Center(child: CircularProgressIndicator()); // Show a loading indicator until data is fetched.
  }
  debugPrint('Selected Tab Index: $_selectedTabIndex');

  // Handle "All" tab
  if (_selectedTabIndex == 0) {
    return const AllItem(complainttype: "All");
  }

  debugPrint('Selected Complaint Type: ${complaintTypes[_selectedTabIndex - 1]}');
  return AllItem(complainttype: complaintTypes[_selectedTabIndex - 1]); // Adjust index for content
}

}
  
  
  
  