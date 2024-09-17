import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichy_iccc_engineer/Controller/status_controller.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/complaintdetail.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:trichy_iccc_engineer/Model/status.dart';
import 'package:trichy_iccc_engineer/Views/Screens/reply_complaint.dart';


class AllItem extends StatefulWidget {
  final String complainttype;
  const AllItem({super.key, required this.complainttype});

  @override
  State<AllItem> createState() => _AllItemState();
}

class _AllItemState extends State<AllItem> {
  List<Grievance> grievanceData = [];
  List<Grievance> filteredGrievanceData = [];
  final StatusController statusController = Get.put(StatusController());
  
 @override
void didUpdateWidget(covariant AllItem oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.complainttype != oldWidget.complainttype) {
    fetchcomplaint();
  }
}
  @override
  void initState() {
    super.initState();
    fetchcomplaint();
    fetchStatusData();
  }
  //  final CustomerCurrentUser _customerController =
  //     Get.put(CustomerCurrentUser());
  Future<void> fetchcomplaint() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userid = prefs.getString('userId');
    //final customer = _customerController.customer;
    
    try {
      final url = ApiUrl.getuserdata(userid!);
      debugPrint('Fetching complaint data from URL: $url');

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
          debugPrint('Decrypted user data: $decryptedData');

          setState(() {
            grievanceData = decryptedJsonList.map((item) {
              return Grievance(
                grievanceId: item['grievance_id'],
                complaintTypeTitle: item['complaint_type_title'],
                deptName: item['dept_name'],
                zoneName: item['zone_name'],
                wardName: item['ward_name'],
                streetName: item['street_name'],
                pincode: item['pincode'],
                complaint: item['complaint'],
                complaintDetails: item['complaint_details'],
                publicUserId: item['public_user_id'],
                publicUserName: item['public_user_name'],
                phone: item['phone'],
                status: item['status'],
                statusflow: item['statusflow'],
                priority: item['priority'],
                createdAt: item['createdAt'],
                updatedAt: item['updatedAt'],
                assignUser: item['assign_user'],
                assignUsername: item['assign_username'],
              );
            }).toList();

            // Filter the grievance data based on complaint type and status
            _filterGrievanceData();
           // _userController.fetchUserData(userid);
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
    // When complaint type is "All", show all grievances initially without filtering by status
    if (widget.complainttype.toLowerCase() == 'all' && _selectedStatus == null) {
      filteredGrievanceData = grievanceData; // Show all data initially
    } else if (widget.complainttype.toLowerCase() == 'all') {
      // If a status is selected, filter by status only
      filteredGrievanceData = grievanceData
          .where((grievance) =>
              grievance.status.toLowerCase() == _selectedStatus!.toLowerCase())
          .toList();
    } else {
      // When a specific complaint type is selected, filter by complaint type and status
      filteredGrievanceData = grievanceData
          .where((grievance) =>
              grievance.complaintTypeTitle.toLowerCase() == widget.complainttype.toLowerCase() &&
              (_selectedStatus == null || grievance.status.toLowerCase() == _selectedStatus!.toLowerCase()))
          .toList();
    }

    // Debug prints to check filtered data
    debugPrint('Filtered grievance data: $filteredGrievanceData');
    debugPrint('Complaint Type: ${widget.complainttype}');
    debugPrint('Selected Status: $_selectedStatus');
  });


    // Debug prints to check filtered data
    debugPrint('Filtered grievance data: $filteredGrievanceData');
    debugPrint('Complaint Type: ${widget.complainttype}');
    debugPrint('Selected Status: $_selectedStatus');
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             const Text('All Grievance',style: TextStyle(fontSize: 18,color: Colors.black),),
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
        if (filteredGrievanceData.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: filteredGrievanceData.length,
            itemBuilder: (context, index) {
              final grievance = filteredGrievanceData[index];
              return AllList(
                statusLabel: _getStatusColor(grievance.status),
                status: grievance.status,
                status2: grievance.priority,
                statusLabel2: _getStatusColor2(grievance.priority),
                username: grievance.publicUserName,
                 comtitile: grievance.complaintTypeTitle,
                 createddate: grievance.createdAt,
                 assign: grievance.assignUsername,
                 depart: grievance.deptName,
                 phone: grievance.phone,
                 statusflow: grievance.statusflow,
                 street: grievance.streetName,
                 updatedate: grievance.updatedAt,
                 ward: grievance.wardName,
                 zone: grievance.zoneName,
                 grievid: grievance.grievanceId,
                 pincode: grievance.pincode,
                 complaindisc: grievance.complaintDetails,
                 complaint: grievance.complaint,
              );
            },
          )
        else
          const Center(child: Text('No grievances to display')),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.green;
      case 'new':
        return Colors.blue;
      case 'Closed':
        return const Color.fromRGBO(0, 63, 91, 1);
      case 'On Hold':
        return Colors.blue;
      case 'Resolved':
        return Colors.green.shade900;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor2(String priority) {
    switch (priority) {
      case 'High':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      case 'Critical':
        return Colors.red;
      case 'Medium':
        return Colors.green;
      default:
        return Colors.green;
    }
  }
}

class AllList extends StatelessWidget {
  final String grievid;
  final String status;
  final String username;
  final String comtitile;
  final String depart;
  final String complaindisc;
  final String createddate;
  final String updatedate;
  final String pincode;
  final String complaint;
  final String ward;
  final String zone;
  final String street;
  final String phone;
  final String statusflow;
  final String assign;
  final Color statusLabel;
  final String status2;
  final Color statusLabel2;
  const AllList({super.key, required this.statusLabel, required this.status, required this.status2, required this.statusLabel2, required this.username, required this.comtitile, required this.depart, required this.createddate, required this.updatedate, required this.ward, required this.zone, required this.street, required this.phone, required this.statusflow, required this.assign, required this.grievid, required this.pincode, required this.complaindisc, required this.complaint});
   String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('MMMM dd yyyy, hh:mm a');
    return formatter.format(dateTime);
  }
   String formatDay(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('EEEE, dd MMMM');
    return formatter.format(dateTime);
  }
   String formatTime(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    return timeFormatter.format(dateTime);
  }

  String formatTimeAgo(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
      final String formattedDate = formatDate(createddate);
      final String timeago = formatTimeAgo(createddate);
    final String formattedTime = formatTime(createddate);
    final String formattedTime2 = formatTime(updatedate);
    final String formattedday2 = formatDay(updatedate);
    final String formattedday = formatDay(createddate);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  ReplyComplaint(status: status, username: username, comtitile: comtitile, depart: depart, createddate: formattedDate, updatedate: formattedTime2, ward: ward, zone: zone, street: street, phone: phone, statusflow: statusflow, assign: assign, statusLabel: statusLabel, status2: status2, statusLabel2: statusLabel2, grievid: grievid, pincode: pincode,complaindisc: complaindisc,timeago:timeago ,createdtime: formattedTime, formateddate: formattedday,formateddate2: formattedday2,complaint: complaint,)));
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
                              grievid,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: statusLabel),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(color: statusLabel, fontSize: 12.0),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: statusLabel2, // You can change the color based on priority
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                status2,
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
                            Text(username, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Container(
                width: screenWidth * 0.27,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          formatTimeAgo(createddate),
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
            ],
          ),
        ),
      ),
    );
  }
}
