import 'package:flutter/material.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/allitem2.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';
import 'package:trichy_iccc_engineer/color.dart';


class DrawerNew extends StatefulWidget {
  const DrawerNew({super.key});

  @override
  State<DrawerNew> createState() => _DrawerNewState();
}

class _DrawerNewState extends State<DrawerNew> {
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: kbackgroundColor,
       appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(onPressed: (){
               Navigator.pushNamed(context, AppPageNames.homeScreen);
            }, 
            icon:const Icon(Icons.arrow_back,color: Colors.black,)),
            title: const Text('Escalation List',style:  TextStyle(fontWeight: FontWeight.w500),),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)]),
                height: 0.8,
              ),
            ),
          ),
      body: const SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
               SizedBox(height: 10,),
            Allitem2(status: 'new',)
            ],
          ),
        ),
      ),
    );
  }
   
}


