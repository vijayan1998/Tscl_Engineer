// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
class ReportsFullView extends StatefulWidget {
  final String grievid;
  final String status;
  final String comtitile;
  final String depart;
  final String complaindisc;
  final String pincode;
  final String ward;
  final String zone;
  final String street;
  final String phone;
  final String timeago;
 
  
  const ReportsFullView({super.key, required this.grievid, required this.status, required this.comtitile, required this.depart, required this.complaindisc, required this.pincode, required this.ward, required this.zone, required this.street, required this.phone, required this.timeago});

  @override
  State<ReportsFullView> createState() => _ReportsFullViewState();
}

class _ReportsFullViewState extends State<ReportsFullView> {
   final List<Uint8List> _imageBytesList = [];
    bool _isLoading = true;
     final PageController _pageController = PageController();
   Future<void> fetchGrievancesimage() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
     
  try {
    final response = await http.get(
      Uri.parse(ApiUrl.imgget(widget.grievid)),
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
         for (var item in decryptedJsonList) {
          String attachmentId = item['attachment'];
          // Fetch and display the image
          await fetchAndDisplayImage(attachmentId);
            await Future.delayed(const Duration(seconds: 2));
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Decryption failed: $e');
      }

    } else {
    }
  } catch (e) {
    print('HTTP request failed: $e');
  }
}
Future<void> fetchAndDisplayImage(String attachmentId) async {
    final url = ApiUrl.getfile(attachmentId);
    // Log the URL

    try {
      final response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {
        String? contentType = response.headers['content-type'];

        if (contentType == null || contentType == 'undefined') {
          contentType = 'image/jpeg'; 
        }

        if (contentType.startsWith('image/')) {
          // Add image bytes to list
          _imageBytesList.add(response.bodyBytes);
         

          // Trigger rebuild
          setState(() {
             
          });
        } else {
        }
      } else {
      }
    } catch (e) {
      print('Image fetch failed: $e');
    }
  }
@override
  void initState() {
    fetchGrievancesimage();
    super.initState();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stack(
            //   children: [
            //   if (_imageBytesList.isNotEmpty)
            //     SizedBox(
            //       height: 410.0, 
            //       child: PageView.builder(
            //         controller:_pageController,
            //         itemCount: _imageBytesList.length,
            //         itemBuilder: (context, index) {
            //           return Image.memory(
            //             _imageBytesList[index],
            //             fit: BoxFit.cover,
            //             width: MediaQuery.of(context).size.width,
            //           );
            //         },
            //       ),
            //     )
            //   else
            //     Image.asset(
            //       "assets/images/report.png",
            //       fit: BoxFit.cover,
            //       height: 410.0,
            //       width: double.infinity,
            //     ),
            //     Align(
            //       alignment: Alignment.topLeft,
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 50,horizontal:10),
            //         child: IconButton(
            //           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            //           onPressed: () {
            //             Navigator.pop(context);
            //             // Navigator.pushNamedAndRemoveUntil(
            //             // context, AppPageNames.homeNavigatorScreen, (route) => false);
            //           },
            //           style: IconButton.styleFrom(
            //             backgroundColor: const Color.fromARGB(255, 215, 229, 241),
            //             padding: const EdgeInsets.only(left: 10),
            //           ),
            //         ),
            //       ),
            //     ),
            //      if (_imageBytesList.isNotEmpty)
            //   Positioned(
            //     right: 0,
            //     left: 10,
            //     top: 380,
            //     child: Center(
            //       child: SmoothPageIndicator(
            //         controller: _pageController,
            //         count: _imageBytesList.length,
            //         effect: const ScrollingDotsEffect(
            //           activeDotColor: Colors.blue,
            //           dotColor: Colors.grey,
            //           dotHeight: 8.0,
            //           dotWidth: 8.0,
            //           spacing: 8.0,
            //         ),
            //       ),
            //     ),
            //   ),
            //   ],
            // ),
             Stack(
      children: [
        // Show the PageView with the images from memory when not loading
        if (!_isLoading && _imageBytesList.isNotEmpty)
          SizedBox(
            height: 410.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _imageBytesList.length,
              itemBuilder: (context, index) {
                return Image.memory(
                  _imageBytesList[index],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                );
              },
            ),
          )
        // Show fallback asset image if no images are available
        else if (!_isLoading && _imageBytesList.isEmpty)
          Image.asset(
            "assets/images/report.png",
            fit: BoxFit.cover,
            height: 410.0,
            width: double.infinity,
          ),

        // Show loading indicator while loading
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),

        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
              style: IconButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 215, 229, 241),
                padding: const EdgeInsets.only(left: 10),
              ),
            ),
          ),
        ),

        // Show the SmoothPageIndicator when images are loaded
        if (!_isLoading && _imageBytesList.isNotEmpty)
          Positioned(
            right: 0,
            left: 10,
            top: 380,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _imageBytesList.length,
                effect: const ScrollingDotsEffect(
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey,
                  dotHeight: 8.0,
                  dotWidth: 8.0,
                  spacing: 8.0,
                ),
              ),
            ),
          ),
      ],
    ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                        widget.comtitile,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          softWrap: true,
                        ),
                      ),
                                        Text(
                   widget.timeago,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                    ],
                  ),

                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                       Text(
                        AppLocalizations.of(context)!.complainno,
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 5,),
                        Text(
                        widget.grievid,
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Column(children: [
                           Row(children: [
                             Text(  AppLocalizations.of(context)!.phonenum1,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                              const Spacer(),
                            SizedBox(width: 150, child: Text(widget.phone,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),softWrap: true,))
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                             Text(  AppLocalizations.of(context)!.address1,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            const Spacer(),
                                                       SizedBox(
                                width: 150,
                                child: Text(
                                  widget.street,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500),
                                      softWrap: true,
                                ),
                              )
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                           Text(  AppLocalizations.of(context)!.pincode,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                           const Spacer(),
                            SizedBox(width: 150, child: Text(widget.pincode,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),softWrap: true,))
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                            Text(  AppLocalizations.of(context)!.zone,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                                const Spacer(),
                            SizedBox(width: 150, child: Text(widget.zone,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),softWrap: true,))
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                           Text(  AppLocalizations.of(context)!.ward,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                               const Spacer(),
                            SizedBox(width: 150, child: Text(widget.ward,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),softWrap: true,))
                          ],),
                           Row(children: [
                           Text(  AppLocalizations.of(context)!.req,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                              const Spacer(),
                            SizedBox(width: 150, child: Text(widget.comtitile,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),softWrap: true,))
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                            Text(  AppLocalizations.of(context)!.department1,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                                const Spacer(),
                            SizedBox(
                              width: 150,
                              child: Text(widget.depart,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                              softWrap: true,))
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            // const Text("Attachments :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            // const SizedBox(width: 30,),
                            // const Icon(Icons.picture_as_pdf_outlined,color: Colors.red,),
                            //  const SizedBox(width: 2,),
                            // const Text("1.3MB",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                            // const SizedBox(width: 2,),
                            // InkWell(onTap: (){},child: const Icon(Icons.file_download_outlined),)
                          
                          ],),
                  ],),
                  Text(
                      widget.complaindisc,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 44,
                   // width: 104,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)) ,
                   child:  Center(
                     child: Text(  AppLocalizations.of(context)!.status,style: const TextStyle(color: Colors.black87,fontSize: 19,fontWeight: FontWeight.w400),
                                       ),
                   ),),
                    Container(
                    height: 44,
                   // width: 104,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: const BoxDecoration(color: Color.fromRGBO(0, 63, 91, 1), ) ,
                   child:  Center(
                     child: Text(widget.status,style: const TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.w400),
                                       ),
                   ),),
                ],
              ),
            ),
            const SizedBox(height: 16.0), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}
