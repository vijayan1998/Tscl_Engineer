import 'package:flutter/material.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/allitem2.dart';


class DrawerOnhold extends StatefulWidget {
  const DrawerOnhold({super.key});

  @override
  State<DrawerOnhold> createState() => _DrawerOnholdState();
}

class _DrawerOnholdState extends State<DrawerOnhold> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
          Allitem2(status: 'on hold',)
          ],
        ),
      ),
    );
  }
}