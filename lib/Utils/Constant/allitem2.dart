
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:trichy_iccc_engineer/Controller/status_controller.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/esclation_model.dart';
import 'package:trichy_iccc_engineer/Model/status.dart';
import 'package:trichy_iccc_engineer/User%20preferences/customer_current.dart';
import 'package:trichy_iccc_engineer/Views/Screens/reply_complaint.dart';


class Allitem2 extends StatefulWidget {
   final String status;
  const Allitem2({super.key, required this.status});

  @override
  State<Allitem2> createState() => _Allitem2State();
}

class _Allitem2State extends State<Allitem2> {
   
  List<EsclationModel> filteredesclationData = [];
  List<EsclationModel> esclationData = [];
  final CustomerCurrentUser _customerController =
    Get.put(CustomerCurrentUser());
   final StatusController statusController = Get.put(StatusController());

     @override
  void initState() {
    super.initState();
    fetchcomplaint();
    fetchStatusData();
  }
   Future<void> fetchcomplaint() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final customer = _customerController.customer;
    
    try {
     final queryParams = {
    'escalation_department': customer.deptname,
    'escalation_to': customer.role,
  };

  final url = Uri.parse(ApiUrl.escalation).replace(queryParameters: queryParams);
      debugPrint('Fetching complaint data from URL: $url');

      final response = await http.get(
        url,
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
          debugPrint('Decrypted user data: $decryptedData');

          setState(() {
            esclationData = decryptedJsonList.map((item) {
              return EsclationModel(
                grievanceId: item['grievance_id'],
                escalatedUser: item['escalated_user']??" ",
                escalatedDue: item['escalated_due']??' ',
                escalationRaisedby: item['escalation_raisedby'],
                escalationPriority: item['escalation_priority'],
                status: item['status'],
                createdAt: item['createdAt'],
              );
            }).toList();
            _filterGrievanceData();

          });

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
void _filterGrievanceData() {
  setState(() {
    // If no specific status is selected, show all grievances
    if (_selectedStatus == null) {
      filteredesclationData = esclationData; // Show all data
    } else {
      // Filter grievances by the selected status
     filteredesclationData = esclationData
          .where((grievance) =>
              grievance.status.toLowerCase() == _selectedStatus!.toLowerCase())
          .toList();
    }

    // Debug prints to check filtered data
    debugPrint('Filtered grievance data: $filteredesclationData');
    debugPrint('Selected Status: $_selectedStatus');
  });
}

  List<StatusModel> statusList = [];
  String? _selectedStatus;

void fetchStatusData() async {
  try {
    List<StatusModel> fetchedStatus = await statusController.getAllStatus();
    setState(() {
      statusList = fetchedStatus;
      _selectedStatus = null; // Initially set to null
    });
  } catch (e) {
    // Handle error
    debugPrint('Error fetching status types: $e');
  }
}
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
             Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             const Text('All Esclation',style: TextStyle(fontSize: 18,color: Colors.black),),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: DropdownButton<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                items: [
                 const DropdownMenuItem<String>(
                    value: null, // This is the placeholder item
                    child: Text(
                      'All', // Placeholder text
                      style: TextStyle(color: Colors.grey), // Optional: style the placeholder
                    ),
                  ),
                  ...statusList.map<DropdownMenuItem<String>>((StatusModel status) {
                    return DropdownMenuItem<String>(
                      value: status.statusname,
                      child: Text(status.statusname),
                    );
                  }),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue; // Update selected status
                    _filterGrievanceData();     // Apply filtering
                  });
                },
                underline: Container(),
              ),
                ),
              ),
            ],
          ),
        ),
          const SizedBox(height: 10),
           if (filteredesclationData.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredesclationData.length,
              itemBuilder: (context, index) {
                 final esclation = filteredesclationData[index];
                return  AllList2(
                grievid: esclation.grievanceId ,
                status: esclation.status,
                priorityLabel2: _getStatusColor2(esclation.escalationPriority),
                createdAt: esclation.createdAt ,
                overdue: esclation.escalatedDue,
                priority: esclation.escalationPriority,
                raisedby: esclation.escalationRaisedby,
                assign: esclation.escalatedUser,

                );
              },
            )
             else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No Data',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor2(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.blue;
      case 'Medium':
        return Colors.green;
      default:
        return Colors.green;
    }
  }
}

class AllList2 extends StatefulWidget {
  final String grievid;
  final String status;
  final String createdAt;
  final String overdue;
  final String raisedby;
  final String priority;
  final Color priorityLabel2;
  final String assign;
  
  const AllList2({super.key, required this.grievid, required this.status, required this.createdAt, required this.overdue, required this.raisedby, required this.priority, required this.priorityLabel2, required this.assign, });

  @override
  State<AllList2> createState() => _AllList2State();
}

class _AllList2State extends State<AllList2> {

 

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
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          _fetchGrievanceDetail(context, widget.grievid);
         // Navigator.push(context, MaterialPageRoute(builder: (context) =>  ReplyComplaint(status: status, username: username, comtitile: comtitile, depart: depart, createddate: formattedDate, updatedate: formattedTime2, ward: ward, zone: zone, street: street, phone: phone, statusflow: statusflow, assign: assign, statusLabel: statusLabel, status2: status2, statusLabel2: statusLabel2, grievid: grievid, pincode: pincode,complaindisc: complaindisc,timeago:timeago ,createdtime: formattedTime, formateddate: formattedday,formateddate2: formattedday2,)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.blue[100],
                    child: SvgPicture.asset(
                      "assets/icons/profile.svg",
                      height: 45,
                      width: 45,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                              widget.grievid,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child:  Text(
                                widget.status,
                                style: const TextStyle(color: Colors.green, fontSize: 12.0),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: widget.priorityLabel2, // You can change the color based on priority
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child:  Text(
                                widget.priority,
                                style: const TextStyle(color: Colors.white, fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                         Row(
                          children: [
                            Text(
                             AppLocalizations.of(context)!.raiseby,
                              style: const TextStyle(fontSize: 12.0, color: Colors.black54, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(width: 3),
                           Text(widget.raisedby, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                 if (widget.overdue.isNotEmpty)
                  Container(
                    width: screenWidth * 0.27,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                     child:   SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: Row(
                            children: [
                               const Text(
                              "Over Due:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                               Text(
                                widget.overdue,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                  if (widget.assign.isNotEmpty)
                  Container(
                    width: screenWidth * 0.27,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child:  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: Row(
                            children: [
                             Text(
                               AppLocalizations.of(context)!.assignto1,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                                Text(
                                widget.assign,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.27,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                            AppLocalizations.of(context)!.date,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                              Text(
                             formatTimeAgo(widget.createdAt),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
