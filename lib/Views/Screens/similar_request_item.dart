// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:trichy_iccc_engineer/Views/Screens/reply_complaint.dart';







class SimilarRequestItem extends StatefulWidget {
  final bool isLastItem;
  final String grievid;
  final String status;
  final String dateandtime;

  const SimilarRequestItem(
      {super.key,
      required this.isLastItem,
      required this.grievid,
      required this.status,
      required this.dateandtime});

  @override
  State<SimilarRequestItem> createState() => _SimilarRequestItemState();
}

class _SimilarRequestItemState extends State<SimilarRequestItem> {
   

Future<void> _fetchGrievanceDetail(BuildContext context, String grievanceId) async {
  final url = ApiUrl.grievancedata(grievanceId); // Update with your actual API endpoint
 final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
   

  try {
    final response = await http.get(
      Uri.parse(url),
     headers: {'Authorization': 'Bearer $token'});

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
        var data = jsonDecode(decryptedData);

        
        String createdDate = data['createdAt'];
        String formattedDate = DateFormat('MMMM dd yyyy, hh:mm a').format(DateTime.parse(createdDate));
        String formattedTime2 = DateFormat('hh:mm a').format(DateTime.parse(data['updatedAt']));
        String formatteddate2 = DateFormat('MMMM dd yyyy').format(DateTime.parse(data['updatedAt']));
        String timeagoText = timeago.format(DateTime.parse(createdDate));

        // Navigate to the ReplyComplaint screen with the decrypted data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReplyComplaint(
              status: data['status'],
              username: data['public_user_name'],
              comtitile: data['complaint_type_title'],
              depart: data['dept_name'],
              createddate: formattedDate,
              updatedate: formattedTime2,
              ward: data['ward_name'],
              zone: data['zone_name'],
              street: data['street_name'],
              phone: data['phone'],
              statusflow: data['statusflow'],
              assign: data['assign_user'],
              statusLabel: Colors.green,
              status2: data['priority'],
              complaint: data['complaint'],
              statusLabel2: Colors.red,
              grievid: data['grievance_id'],
              pincode: data['pincode'],
              complaindisc: data['complaint_details'],
              timeago: timeagoText,
              createdtime: DateFormat('hh:mm a').format(DateTime.parse(createdDate).toLocal()),
              formateddate: DateFormat('dd/MM/yyyy').format(DateTime.parse(createdDate).toLocal()),
              formateddate2: formatteddate2,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Decryption failed: $e');
      }
    } else {
      debugPrint('Failed to fetch grievance details: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('HTTP request failed: $e');
  }
}


  String formatTimeAgo(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: (){
            _fetchGrievanceDetail(context, widget.grievid);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  widget.grievid,
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(widget.status,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      )),
                ),
                Expanded(
                  child: Text(
                    widget.dateandtime,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
