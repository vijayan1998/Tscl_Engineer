import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trichy_iccc_engineer/Views/Screens/Authentication/otp_forget_password.dart';
import 'package:trichy_iccc_engineer/Views/Widgets/buttons.dart';
import 'package:trichy_iccc_engineer/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _phoneNumberController =
      TextEditingController(text: "+91");
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  bool _isLoading = false;
  Future<void> _sendOtp() async {
    String phoneNumber = _phoneNumberController.text.trim();

    setState(() {
      _isLoading = true;
    });

    // await FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: phoneNumber,
    //   verificationCompleted: (PhoneAuthCredential credential) {},
    //   verificationFailed: (FirebaseAuthException e) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Failed to send OTP: ${e.message}")),
    //     );
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   },
    //   codeSent: (String verificationId, int? resendToken) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    // Navigator.pushNamed(
    //   context,
    //   AppPageNames.signUpOtpScreen,
    //   arguments: {
    //     'verificationId': verificationId,
    //     'fullName': _fullNameController.text.trim(),
    //     'phoneNumber': phoneNumber,
    //     'email': _emailController.text.trim(),
    //     'password': _passwordController.text.trim(),
    //   },
    // );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpForgetPassword(
                verificationId: " ", phoneNumber: phoneNumber)));
    //   },
    //   codeAutoRetrievalTimeout: (String verificationId) {},
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: IconButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 215, 229, 241),
                            padding: const EdgeInsets.only(left: 9)),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.forgetpassword,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.black),
                      inputFormatters: [
                       
                        LengthLimitingTextInputFormatter(13),
                      ],
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.phonenum,
                        hintStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                width: 2.0)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                width: 2.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (value.length != 13) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 482,
                    ),
                    Center(
                        child: CustomFillButton(
                            buttontext: AppLocalizations.of(context)!.contin,
                            buttoncolor: maincolor,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _sendOtp();
                              }
                            },
                            minimumSize: const Size(301, 54),
                            buttontextsize: 20)),
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
