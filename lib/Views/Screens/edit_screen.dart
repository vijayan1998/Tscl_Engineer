// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trichy_iccc_engineer/Controller/dept_request.dart';
import 'package:trichy_iccc_engineer/Controller/grievance_detail.dart';
import 'package:trichy_iccc_engineer/Model/customer.dart';
import 'package:trichy_iccc_engineer/User%20preferences/customer_current.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';
import 'package:trichy_iccc_engineer/Views/Widgets/buttons.dart';
import 'package:trichy_iccc_engineer/Views/Widgets/textfield.dart';
import 'package:trichy_iccc_engineer/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditScreen extends StatefulWidget {
  final Object? arugment;
  const EditScreen({super.key, this.arugment});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  final CustomerCurrentUser currentUser = Get.put(CustomerCurrentUser());
  final DeptController deptController = Get.put(DeptController());
  final GrievanceController grievanceController = Get.put(GrievanceController());
  final CustomerCurrentUser _customerController =Get.put(CustomerCurrentUser());
   GrievanceController userController = Get.put(GrievanceController());
  CustomerModel customer = CustomerModel();
     final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   void setChatScreenParameter(Object? argument) {
    if (argument != null && argument is CustomerModel) {
      customer = argument;
    }
  }

@override
  void initState() {
    _customerController.getUserInfo();
    setChatScreenParameter(widget.arugment);
    usernameController.text = customer.userName.toString();
    addressController.text = customer.address.toString();
    pincodeController.text = customer.pincode.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customerController.customer;
    return  Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(8),
            child: Row(children: [
              IconButton(onPressed: (){
                Navigator.pushNamed(context, AppPageNames.profileScreen);
                 },style: IconButton.styleFrom(
           backgroundColor: const Color.fromARGB(255, 215, 229, 241),
           padding:  const EdgeInsets.only(left: 9)
                 ), icon: const Icon(Icons.arrow_back_ios,)),
                 const SizedBox(width: 10,),
          Text(AppLocalizations.of(context)!.editprofile,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),
            ],),
            ),
            const SizedBox(height: 10,),
             Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                 key: _formKey,  
                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                      CustomTextField(hinttext: customer.userName ?? 'Profile name',controller: usernameController,),
                                       const SizedBox(height: 10,),
                                      CustomTextField(hinttext:customer.address ?? "Address",controller: addressController,),
                                       const SizedBox(height: 10,),
                                     
                                         TextFormField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: customer.pincode ?? 'Pincode',
                   hintStyle: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: const BorderSide(
                                                  color:
                                                      Color.fromRGBO(0, 0, 0, 0.1),
                                                  width: 2.0)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: const BorderSide(
                                                  color:
                                                    Color.fromRGBO(0, 0, 0, 0.1),
                                                  width: 2.0)),
                ),
                 validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a pincode';
                    } else if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    return null; 
                  },),
                                       const SizedBox(height: 300,),   
                                       Center(child: CustomFillButton(buttontext: AppLocalizations.of(context)!.updateprof, buttoncolor: maincolor, 
                                       onPressed: (){
                                          if (_formKey.currentState!.validate()) {
                                        grievanceController.editprofile(context, customer.userId.toString(),
                                        usernameController.text,addressController.text,pincodeController.text);
                                          }
                                       }, minimumSize: const Size(301, 54), buttontextsize: 20)),      
                                       ],
                                     ),
              )
                  
              
            ),   
          ],
                ),
        ),
      ),
    );
  }
}