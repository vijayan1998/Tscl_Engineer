import 'package:flutter/material.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/allitem2.dart';

class DrawerResolved extends StatefulWidget {
  const DrawerResolved({super.key});

  @override
  State<DrawerResolved> createState() => _DrawerResolvedState();
}

class _DrawerResolvedState extends State<DrawerResolved> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
          Allitem2(status: 'resolved',)
          ],
        ),
      ),
    );
  }
}