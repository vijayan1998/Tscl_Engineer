// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichy_iccc_engineer/Controller/status_controller.dart';
import 'package:trichy_iccc_engineer/Controller/user_attachment.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/log_model.dart';
import 'package:trichy_iccc_engineer/Model/similar_request.dart';
import 'package:trichy_iccc_engineer/Model/status.dart';
import 'package:trichy_iccc_engineer/User%20preferences/customer_current.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';
import 'package:trichy_iccc_engineer/Views/Screens/attachment.dart';
import 'package:trichy_iccc_engineer/Views/Screens/reports_full_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:trichy_iccc_engineer/Views/Screens/similar_request_item.dart';

class ReplyComplaint extends StatefulWidget {
  final String grievid;
  final String status;
  final String username;
  final String comtitile;
  final String depart;
  final String complaindisc;
  final String createddate;
  final String createdtime;
  final String updatedate;
  final String pincode;
  final String ward;
  final String zone;
  final String street;
  final String phone;
  final String statusflow;
  final String assign;
  final Color statusLabel;
  final String status2;
  final String timeago;
  final String formateddate;
  final String formateddate2;
  final Color statusLabel2;
  final String complaint;
  const ReplyComplaint(
      {super.key,
      required this.status,
      required this.username,
      required this.comtitile,
      required this.depart,
      required this.createddate,
      required this.updatedate,
      required this.ward,
      required this.zone,
      required this.street,
      required this.phone,
      required this.statusflow,
      required this.assign,
      required this.statusLabel,
      required this.status2,
      required this.statusLabel2,
      required this.grievid,
      required this.pincode,
      required this.timeago,
      required this.formateddate,
      required this.complaindisc,
      required this.createdtime,
      required this.formateddate2,
      required this.complaint});

  @override
  State<ReplyComplaint> createState() => _ReplyComplaintState();
}

class _ReplyComplaintState extends State<ReplyComplaint> {
  bool _isBottomContainerVisible = false;
  bool _isBottomContainerVisible2 = false;
  bool _isStatusClosed = false;
  bool _isStatusClosed2 = false;
  late String selectedStatus = widget.status;
  final StatusController statusController = Get.put(StatusController());
  final TextEditingController _textController = TextEditingController();
  final UserImageController userImageController =
      Get.put(UserImageController());
  final CustomerCurrentUser _customerController =
      Get.put(CustomerCurrentUser());

  List<SimilarRequest> similarRequests = [];

  List<LogDetail> logDetails = [];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
    fetchStatusData();
    fetchLogDetails(widget.grievid);
    userImageController.fetchLogAttachment(widget.grievid);
    fetchSimilarRequests();
    _customerController.getUserInfo();
    if (selectedStatus.toLowerCase() == 'closed') {
      _isStatusClosed = true;
    }
  }

  void _toggleBottomContainer2() {
    setState(() {
      _isBottomContainerVisible2 = !_isBottomContainerVisible2;
    });
  }

  void _toggleBottomContainer() {
    setState(() {
      _isBottomContainerVisible = !_isBottomContainerVisible;
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
void _showSimilarRequestsDialog(BuildContext context) {
  if (similarRequests.isEmpty) {
    return;
  }

  // Map to track the status of each grievance (whether closed or not)
  final Map<String, bool> closedStatusMap = {};

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('MMMM dd yyyy, hh:mm a');
    return formatter.format(dateTime);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Similar Requests'),
            content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: similarRequests.length,
                    itemBuilder: (context, index) {
                      final request = similarRequests[index];
                      final String formattedDate = formatDate(request.createdAt);

                      // Initialize the map for each grievance
                      closedStatusMap.putIfAbsent(request.grievanceId, () => false);

                      return ExpansionTile(
                        title: Text('Grievance ID: ${request.grievanceId}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    Container(
                                      height: 28,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: request.status,
                                            onChanged: closedStatusMap[request.grievanceId]! ? null : (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  request.status = newValue;
                                                  selectedStatus = newValue;
                                                });

                                                if (newValue.toLowerCase() == 'closed' &&
                                                    _textController.text.isNotEmpty) {
                                                  // Mark this particular grievance as closed
                                                  setState(() {
                                                    closedStatusMap[request.grievanceId] = true;
                                                  });
                                                  postData2(request.grievanceId); // Post the text data
                                                  _postStatusToApi3(newValue, request.grievanceId);
                                                } else if (newValue.toLowerCase() == 'closed') {
                                                  Fluttertoast.showToast(
                                                    msg: "Please enter text before selecting closed status",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  );
                                                } else if (newValue.toLowerCase() != 'new') {
                                                  _postStatusToApi3(newValue, request.grievanceId);
                                                }
                                              }
                                            },
                                            items: statusList
                                                .map<DropdownMenuItem<String>>((StatusModel status) {
                                              return DropdownMenuItem<String>(
                                                value: status.statusname.toLowerCase(),
                                                child: Text(status.statusname),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Desc:"),
                                    const Spacer(),
                                    SizedBox(
                                      width: 100,
                                      child: Text(request.complaindisc, softWrap: true),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("department :"),
                                    const Spacer(),
                                    SizedBox(
                                      width: 100,
                                      child: Text(request.deptname, softWrap: true),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Date :"),
                                    const Spacer(),
                                    Text(formattedDate),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    })),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen, (route) => false);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}


  Future<void> fetchSimilarRequests() async {
    // Adding query parameters
    final queryParams = {
      'zone_name': widget.zone,
      'ward_name': widget.ward,
      'street_name': widget.street,
      'dept_name': widget.depart,
      'complaint': widget.complaint,
    };

    final uri =
        Uri.parse(ApiUrl.similarrequest).replace(queryParameters: queryParams);
    debugPrint('Request URI: $uri');

    // Fetch token from shared preferences if required
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // Assuming the token is stored

    // Encryption key and IV
    final key = encrypt.Key.fromBase16(
        '9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
    final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token', // Use token if needed
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Response body: ${response.body}');
        var json = jsonDecode(response.body);

        try {
          // Assuming the response data needs decryption
          final encryptedData = encrypt.Encrypted.fromBase16(json['data']);
          final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
          final List<dynamic> decryptedJsonList = jsonDecode(decryptedData);
            debugPrint('Fetching Similar details from : $decryptedJsonList');
          // setState(() {
          //   similarRequests = decryptedJsonList
          //       .map((item) => SimilarRequest.fromJson(item))
          //       .toList();
          // });
            final filteredRequests = decryptedJsonList
            .where((item) => item['grievance_id'] != widget.grievid)
            .toList();

        // Update the UI with the filtered similar requests
        setState(() {
          similarRequests = filteredRequests
              .map((item) => SimilarRequest.fromJson(item))
              .toList();
        });

        } catch (e) {
          debugPrint('Decryption failed: $e');
        }
      } else {
        debugPrint("Failed to fetch similar requests: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network or other error: $e");
    }
  }

  Future<void> _pickFiles() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();

      for (var file in pickedFiles) {
        final fileBytes = await file.readAsBytes();
        final fileSizeInKB = fileBytes.lengthInBytes / 1024;

        if (fileSizeInKB <= 400) {
          if (_selectedFiles.length < 5) {
            setState(() {
              _selectedFiles.add(file);
            });
          } else {
            Fluttertoast.showToast(
              msg: 'You can only select up to 5 images in total',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 15.0,
            );
            break;
          }
        } else {
          Fluttertoast.showToast(
            msg: 'File ${file.name} exceeds 400KB and was not added',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  Future<void> _uploadFiles(String grievanceId) async {
    if (_selectedFiles.isEmpty) return;

    final uri = Uri.parse(ApiUrl.replyComplainAttach);

    final request = http.MultipartRequest('POST', uri)
      ..fields['grievance_id'] = grievanceId
      ..fields['created_by_user'] = 'user';

    for (var file in _selectedFiles) {
      final multipartFile =
          await http.MultipartFile.fromPath('files', file.path);
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchLogDetails(String grievanceId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final url = ApiUrl.grievlogget(grievanceId); // Replace with your API URL
      debugPrint('Fetching log details from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        // Decryption key and IV
        final key = encrypt.Key.fromBase16(
            '9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
        final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
        final encrypter = encrypt.Encrypter(
            encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

        try {
          // Decrypt the encrypted data
          final encryptedData = encrypt.Encrypted.fromBase16(json['data']);
          final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
          List<dynamic> decryptedJsonList = jsonDecode(decryptedData);
          // debugPrint('Decrypted log data: $decryptedData');

          setState(() {
            logDetails = decryptedJsonList.map((item) {
              return LogDetail.fromJson(item); // Use the factory constructor
            }).toList();

            logDetails.sort((a, b) => DateTime.parse(b.createdAt)
                .compareTo(DateTime.parse(a.createdAt)));
            // for (var item in decryptedJsonList) {
            //   debugPrint('Sorted log detail: $item');
            // }
          });
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

  Future<void> _postStatusToApi2(String newStatus,String grievid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse(ApiUrl.updatestatus(grievid)),
      body: jsonEncode({
        'status': newStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //  Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen,(route)=> false);
    } else {}
    final response2 = await http.post(
      Uri.parse(ApiUrl.grievanceLog),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'grievance_id': widget.grievid,
        'log_details':
            "working is status : $newStatus update by  ${_customerController.customer.userName}"
      }),
    );
    if (response2.statusCode == 200) {
      // Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen, (route) => false);
      _showSimilarRequestsDialog(context);
    } else {
      debugPrint('Second API call failed');
    }
  }
  

  Future<void> _postStatusToApi(String newStatus,String grievid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse(ApiUrl.updatestatus(grievid)),
      body: jsonEncode({
        'status': newStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //  Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen,(route)=> false);
    } else {}
    final response2 = await http.post(
      Uri.parse(ApiUrl.grievanceLog),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'grievance_id': grievid,
        'log_details':
            "working is status : $newStatus update by  ${_customerController.customer.userName}"
      }),
    );
    if (response2.statusCode == 200) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppPageNames.homeScreen, (route) => false);
    } else {
      debugPrint('Second API call failed');
    }
  }
  
  Future<void> _postStatusToApi3(String newStatus,String grievid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse(ApiUrl.updatestatus(grievid)),
      body: jsonEncode({
        'status': newStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //  Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen,(route)=> false);
    } else {}
    final response2 = await http.post(
      Uri.parse(ApiUrl.grievanceLog),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'grievance_id': grievid,
        'log_details':
            "working is status : $newStatus update by  ${_customerController.customer.userName}"
      }),
    );
    if (response2.statusCode == 200) {
      // Navigator.pushNamedAndRemoveUntil(
      //     context, AppPageNames.homeScreen, (route) => false);
    } else {
      debugPrint('Second API call failed');
    }
  }

  List<StatusModel> statusList = [];
  String? _selectedStatus;

  void fetchStatusData() async {
    try {
      List<StatusModel> fetchedStatus = await statusController.getAllStatus();
      setState(() {
        statusList = fetchedStatus;
        _selectedStatus =
            statusList.isNotEmpty ? widget.status.toLowerCase() : null;
      });
    } catch (e) {
      // Handle error
      debugPrint('Error fetching status types: $e');
    }
  }

  Future<void> postData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final url = ApiUrl.replycomplain; // Replace with your API endpoint
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "grievance_id": widget.grievid,
          "worksheet_name": _textController.text
        }));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Submitted Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (_selectedFiles.isNotEmpty) {
        await _uploadFiles(widget.grievid);
      }
      final secondResponse = await http.post(
        Uri.parse(ApiUrl.grievanceLog),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'grievance_id': widget.grievid,
          'log_details': "worksheet : ${_textController.text}"
        }),
      );
   
      if (secondResponse.statusCode == 200) {
        fetchLogDetails(widget.grievid);
      } else {
        // Handle error for the second API
        debugPrint('Failed to post data to the second API');
      }
    } else {
      // Handle error
      debugPrint('Failed to post data');
    }
  }

  Future<void> postData2(String grievid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final url = ApiUrl.replycomplain; // Replace with your API endpoint
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "grievance_id": grievid,
          "worksheet_name": _textController.text
        }));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Sumitted Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (_selectedFiles.isNotEmpty) {
        await _uploadFiles(grievid);
      }
      final secondResponse = await http.post(
        Uri.parse(ApiUrl.grievanceLog),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'grievance_id': grievid,
          'log_details': "worksheet : ${_textController.text}"
        }),
      );
   
      if (secondResponse.statusCode == 200) {
        fetchLogDetails(grievid);
      } else {
        // Handle error for the second API
        debugPrint('Failed to post data to the second API');
      }
    } else {
      // Handle error
      debugPrint('Failed to post data');
    }
  }

  

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

  String formatDatelog(String dateTime) {
    final DateFormat dateFormat = DateFormat('EEEE, dd MMMM');
    final DateTime date = DateTime.parse(dateTime).toLocal();
    return dateFormat.format(date);
  }

  String formatTimelog(String? createdString) {
    if (createdString != null) {
      DateTime createdAt = DateTime.parse(createdString).toLocal();
      return DateFormat('hh:mm a').format(createdAt);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 252, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
            color: Colors.black), // Ensure the drawer icon is visible
        title: const Text(
          "Reply complaint",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.92,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.reqoverview,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.complainno,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.grievid,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            const Spacer(),
                            Container(
                              height: 28,
                              width: 140,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 3.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: _selectedStatus?.toLowerCase(),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.blue),
                                      isExpanded: true,
                                      items: statusList
                                          .map<DropdownMenuItem<String>>(
                                              (StatusModel status) {
                                        return DropdownMenuItem<String>(
                                          value:
                                              status.statusname.toLowerCase(),
                                          child: Text(status.statusname),
                                        );
                                      }).toList(),
                                      onChanged: _isStatusClosed
                                          ? null
                                          : (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectedStatus = newValue;
                                                });
                                                // If the newValue is 'closed' and the text field is not empty
                                                if (newValue.toLowerCase() ==
                                                        'closed' &&
                                                    _textController
                                                        .text.isNotEmpty) {
                                                  postData(); 
                                                  _postStatusToApi2(newValue,widget.grievid);
                                                  _isStatusClosed = true;
                                                } else if (newValue
                                                        .toLowerCase() ==
                                                    'closed') {
                                                  // Show a warning toast if trying to select 'closed' without text
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Please enter text before selecting closed status",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  );
                                                } else if (newValue
                                                        .toLowerCase() !=
                                                    'new') {
                                                  // For all other statuses except 'New', call _postStatusToApi()
                                                  _postStatusToApi(newValue,widget.grievid);
                                                }
                                              }
                                            }

                                      // underline: Container(),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.createddate,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.raiseby,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.username,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.department,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: 130,
                              child: Text(
                                widget.depart,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                                softWrap: true,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              height: 23,
                              //width: 43,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.amber),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Center(
                                    child: Text(
                                  widget.status,
                                  style: const TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Container(
                    width: screenWidth * 0.9,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(244, 252, 255, 1),
                        boxShadow: [BoxShadow(color: Colors.grey)]),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)!.grivedetail,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleBottomContainer2,
                          icon: Icon(_isBottomContainerVisible2
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                        )
                      ],
                    ),
                  ),
                  if (_isBottomContainerVisible2)
                    Container(
                      width: screenWidth * 0.9,
                      // height: screenHeight * 0.43,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.phonenum1,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.phone,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.address1,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.street,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.pincode,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.pincode,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.zone,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.zone,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.ward,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.ward,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.req,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.comtitile,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.department1,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.depart,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReportsFullView(
                                            grievid: widget.grievid,
                                            status: widget.status,
                                            comtitile: widget.comtitile,
                                            depart: widget.depart,
                                            complaindisc: widget.complaindisc,
                                            pincode: widget.pincode,
                                            ward: widget.ward,
                                            zone: widget.zone,
                                            street: widget.street,
                                            phone: widget.phone,
                                            timeago: widget.timeago,
                                          )),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.reqfullview,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  Container(
                    width: screenWidth * 0.9,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(244, 252, 255, 1),
                        boxShadow: [BoxShadow(color: Colors.grey)]),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)!.complainhis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        const SizedBox(
                          width: 3,
                        ),
                        Text("#${widget.grievid}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54)),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleBottomContainer,
                          icon: Icon(_isBottomContainerVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                        )
                      ],
                    ),
                  ),
                  if (_isBottomContainerVisible)
                    // Display additional data after all log details
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (logDetails.isNotEmpty) ...[
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: logDetails.length +
                                              1, // +1 to include additional data after log details
                                          itemBuilder: (context, index) {
                                            if (index < logDetails.length) {
                                              // Display log details
                                              final log = logDetails[index];
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    formatDatelog(
                                                        log.createdAt),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          formatTimelog(
                                                              log.createdAt),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 40),
                                                        Container(
                                                          height: 25,
                                                          width: 1.5,
                                                          color: Colors.black,
                                                        ),
                                                        const SizedBox(
                                                            width: 30),
                                                        Expanded(
                                                          child: Text(
                                                            log.logMessage,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return null;
                                          }),
                                      if (userImageController
                                          .logDetails.isNotEmpty) ...[
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: userImageController
                                                    .logDetails.length +
                                                1, // +1 to include additional data after log details
                                            itemBuilder: (context, index) {
                                              if (index <
                                                  userImageController
                                                      .logDetails.length) {
                                                // Display log details
                                                final log = userImageController
                                                    .logDetails[index];

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      formatDatelog(
                                                          log.createdAt),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            formatTimelog(
                                                                log.createdAt),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 40),
                                                          Container(
                                                            height: 25,
                                                            width: 1.5,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(
                                                              width: 30),
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                AttachmentPage(attachment: log.attachment)));
                                                              },
                                                              child: Text(
                                                                "Attachment: ${log.attachment}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return null;
                                            })
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (widget.formateddate.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                widget.formateddate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (widget.createdtime.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    logDetailRow(widget.createdtime,
                                        "Ticket Raised- ${widget.grievid}"),
                                    const SizedBox(height: 10),
                                    logDetailRow(widget.createdtime,
                                        "Assigned to particular ${widget.depart} department"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.status,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: const BoxDecoration(
                                          color: Color.fromRGBO(0, 63, 91, 1)),
                                      child: Center(
                                        child: Text(
                                          widget.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: screenWidth * 0.9,
                    color: Colors.white,
                    //  padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Similar request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        
                        similarRequests.isEmpty
                            ? const Center(
                                child: Text('No similar requests found'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: similarRequests.length,
                                itemBuilder: (context, index) {
                                  final request = similarRequests[index];
                                  return SimilarRequestItem(
                                    isLastItem:
                                        index == similarRequests.length - 1,
                                    grievid: request.grievanceId,
                                    status: request.status,
                                    dateandtime: formatDate(request.createdAt),
                                  );
                                },
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0)
            .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: _selectedFiles.isNotEmpty ? 150 : 90,
          child: BottomAppBar(
            child: Column(
              children: [
                Visibility(
                  visible: _selectedFiles.isNotEmpty,
                  child: Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                          leading: const Icon(Icons.file_present),
                          title: Text(_selectedFiles[index].name),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => _removeFile(index),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.image),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: 'Type...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_textController.text.isNotEmpty) {
                             await postData();
                              if (selectedStatus == 'closed') {
                                _postStatusToApi(selectedStatus,widget.grievid);
                              }
                               _textController.clear();
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please enter text",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logDetailRow(String time, String message) {
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(width: 40),
        Container(
          height: 25,
          width: 1.5,
          color: Colors.black,
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
