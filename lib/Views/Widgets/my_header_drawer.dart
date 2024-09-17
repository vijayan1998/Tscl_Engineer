import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trichy_iccc_engineer/Controller/grievance_detail.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
 
     final GrievanceController getuserid = Get.put(GrievanceController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      final user = getuserid.userModel.value;
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            CircleAvatar(
                          radius: 40,
                          child: Text(
                           (user.userName?.isNotEmpty ?? false)
      ? user.userName![0].toUpperCase()
      : 'N' ,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
         Text(user.userName!,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
         Text(user.userId!,style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w500,color: Colors.black54),)
      ],),
    );
  }
}