import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trichy_iccc_engineer/Controller/user_attachment.dart';

class AttachmentPage extends StatefulWidget {
  final String attachment;
  const AttachmentPage({super.key, required this.attachment});

  @override
  State<AttachmentPage> createState() => _AttachmentPageState();
}

class _AttachmentPageState extends State<AttachmentPage> {
  final UserImageController userImageController = Get.put(UserImageController());

  @override
  void initState() {
    super.initState();
    // Fetch image when the page is initialized
    userImageController.fetchAndDisplayImage(widget.attachment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (userImageController.imageBytesList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          Uint8List imageBytes = userImageController.imageBytesList.first;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 14,
                left: MediaQuery.of(context).size.width / 14,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
