// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';
import 'package:trichy_iccc_engineer/Views/Widgets/buttons.dart';
import 'package:trichy_iccc_engineer/color.dart';

class NewPassword extends StatefulWidget {
  final String phone;
  const NewPassword({super.key, required this.phone});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
 bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;
  String? passwordErrorText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


       @override
  void initState() {
    super.initState();

    _confirmPasswordController.addListener(() {
      _validatePasswords();
    });
  }

     void _validatePasswords() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (confirmPassword.isNotEmpty && newPassword != confirmPassword) {
        passwordErrorText = "Passwords do not match";
      } else {
        passwordErrorText = null;
      }
    });
  }
String? _validatePasswordStrength(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  } else if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  } else if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  } else if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  } else if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
    return 'Password must contain at least one digit';
  } else if (!RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(value)) {
    return 'Password must contain at least one special character';
  }
  return null;
}


     Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
    final newPassword = _newPasswordController.text;
    

    final response = await http.post(
      Uri.parse(ApiUrl.forgetpass(widget.phone.substring(3))), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'login_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Password changed successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushNamedAndRemoveUntil(context, AppPageNames.loginScreen, (route)=>false);
      // Navigate to another screen or refresh the current screen
    } else {
      Fluttertoast.showToast(
        msg: "Failed to change password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }     }else {
    Fluttertoast.showToast(
      msg: "Please fill all fields correctly",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(child: Form(
          key: _formKey,
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.all(8),
              child: Row(children: [
                IconButton(onPressed: (){
            Navigator.pop(context);
           },style: IconButton.styleFrom(
             backgroundColor: const Color.fromARGB(255, 215, 229, 241),
             padding:  const EdgeInsets.only(left: 9)
           ), icon: const Icon(Icons.arrow_back_ios,)),
              ],),
              ),
              const SizedBox(height: 10,),
               Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(AppLocalizations.of(context)!.newpass,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                  const SizedBox(height: 20,),
                
                  TextFormField(
                        controller: _newPasswordController,
                        obscureText: !isPasswordVisible,
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.newpass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              width: 2.0,
                            ),
                          ),
                        ),
                         validator: _validatePasswordStrength,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      
                const SizedBox(height: 10,),
                 TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !isPasswordVisible,
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.confirmpass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              width: 2.0,
                            ),
                          ),
                        ),
                                validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                     autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                  const SizedBox(height: 412,),
          
                  Center(child: CustomFillButton(buttontext: AppLocalizations.of(context)!.contin, buttoncolor: maincolor, onPressed: _changePassword, minimumSize: const Size(301, 54), buttontextsize: 20)),
                  
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}