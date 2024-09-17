import 'package:flutter/material.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/allitem2.dart';


class DrawerInprogress extends StatefulWidget {
  const DrawerInprogress({super.key});

  @override
  State<DrawerInprogress> createState() => _DrawerInprogressState();
}

class _DrawerInprogressState extends State<DrawerInprogress> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
          Allitem2(status: 'in progress',)
          ],
        ),
      ),
    );
  }
}