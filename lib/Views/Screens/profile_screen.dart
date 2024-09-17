// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichy_iccc_engineer/Controller/dept_request.dart';
import 'package:trichy_iccc_engineer/Model/api_url.dart';
import 'package:trichy_iccc_engineer/Model/customer.dart';
import 'package:trichy_iccc_engineer/User%20preferences/customer_current.dart';
import 'package:trichy_iccc_engineer/User%20preferences/token_preferance.dart';
import 'package:trichy_iccc_engineer/User%20preferences/user_prefernces.dart';
import 'package:trichy_iccc_engineer/Utils/Constant/app_pages_names.dart';
import 'package:trichy_iccc_engineer/Views/Screens/edit_screen.dart';
import 'package:trichy_iccc_engineer/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
   final CustomerCurrentUser _customerController = Get.put(CustomerCurrentUser());
   final DeptController deptController = Get.put(DeptController());
   
  
  @override
  void initState() {
    super.initState();
    _customerController.getUserInfo();
  }

Future<void> _deleteAccount() async {
  final customer = _customerController.customer;
  final userid = customer.userId;
   final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  if (userid == null || userid.isEmpty) {
    Fluttertoast.showToast(
      msg: 'Error: Userid is null or empty',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return;
  }

  try {

     final response = await http.delete(
      Uri.parse(ApiUrl.deleteacc(customer.userId!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      
    );

    if (mounted) {
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Account deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        await RememberUserPrefs.removeUserInfo();
        await RememberUserPre.removeToken();
        Navigator.pushNamedAndRemoveUntil(
            context, AppPageNames.loginScreen, (route) => false);
      } else {
        // Print the response body for more information on why the deletion failed
        Fluttertoast.showToast(
          msg: 'Failed to delete account: ${response.body}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  } catch (e) {
    if (mounted) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Print the error for more information
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(onPressed: (){
               Navigator.pushNamed(context, AppPageNames.homeScreen);
            }, 
            icon:const Icon(Icons.arrow_back,color: Colors.black,)),
            title:  Text(AppLocalizations.of(context)!.setti,style: const TextStyle(fontWeight: FontWeight.w500),),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)]),
                height: 0.8,
              ),
            ),
          ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: deptController.fetchUserData1(),
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                } else if(snapshot.hasError){
                  return Center(child: Text('Error : ${snapshot.hasError}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No user data found.'));
                }else {
                 List<CustomerModel> userlist = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: userlist.length,
                  itemBuilder: (context,index){
                    return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                     CircleAvatar(
                      radius: 40,
                      child: Text(
                            userlist[index].userName!.substring(0,1).toUpperCase() ,style: const TextStyle(
                            fontSize: 24,
                          ),), 
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                            userlist[index].userName ?? 'Profile name',  style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                        const SizedBox(height: 4),
                       Text(
                            userlist[index].deptname ?? 'Department name',  style: const TextStyle(
                            color: Colors.grey
                          ),),
                      ],
                    ),
                const Spacer(),
                IconButton(
                icon: SvgPicture.asset("assets/icons/tabler-icon-pencil-plus.svg"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditScreen(arugment: userlist[index],)));
                },
              ),
              ],
              );
                  },
                );
                }
              },
            ),
            const SizedBox(height: 24),
            SettingsOption(
              icon: "assets/icons/tabler-icon-lock.svg",
              title: AppLocalizations.of(context)!.changepass,
              onTap: () {
                 Navigator.pushNamed(context, AppPageNames.changePassword);
              },
            ),
            const SizedBox(height: 10),
            // SettingsOption(
            //   icon: "assets/icons/hugeicons_question.svg",
            //   title: AppLocalizations.of(context)!.faq,
            //   onTap: () {
            //     Navigator.pushNamed(context, AppPageNames.faqScreen);
            //   },
            // ),
            // const SizedBox(height: 10),
            SettingsOption(
              icon: "assets/icons/Vector.svg",
              title: AppLocalizations.of(context)!.lang,
              onTap: () {
                Navigator.pushNamed(context, AppPageNames.languageScreen);
              },
            ),
            const SizedBox(height: 10),
            SettingsOption(
              icon: "assets/icons/tabler-icon-trash.svg",
              title: AppLocalizations.of(context)!.deleacc,
              onTap: () {
                dialogBox(context, 
                AppLocalizations.of(context)!.deleacc,
                AppLocalizations.of(context)!.deleaccdisc,
                "assets/icons/tabler-icon-trash-x.svg", 
                (){
                   Navigator.of(context).pop(); // Close the dialog first
              _deleteAccount();
                },
                AppLocalizations.of(context)!.cancel,
                AppLocalizations.of(context)!.contin
                );
                
              },
            ),
            const SizedBox(height: 10),
            SettingsOption(
              icon: "assets/icons/tabler-icon-logout.svg",
              title: AppLocalizations.of(context)!.logout,
              onTap: (){
                dialogBox(context, 
                AppLocalizations.of(context)!.logout, 
                AppLocalizations.of(context)!.logoutdisc, 
                "assets/icons/tabler-icon-logout.svg", 
                () async {
                    await RememberUserPre.removeToken();
                    await RememberUserPrefs.removeUserInfo().then((value) {
                              Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppPageNames.loginScreen,
                      (route) => false,
                    );
                 });
                }, 
                 AppLocalizations.of(context)!.cancel, 
                AppLocalizations.of(context)!.logout);
              }
            ),
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

   dialogBox(BuildContext context,String title,String desc,String image,void Function()? onchanged,
   String canceltext,String continueText) {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kbackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               SvgPicture.asset(image,height: 50,width: 50,),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16.0),
               Text(
                desc,
              
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 OutlinedButton(onPressed: (){
                   Navigator.pop(context);
                 },  style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red, 
         padding: const EdgeInsets.symmetric(horizontal: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: Colors.red),
      ),
      child:  Text(
        canceltext,  
        style: const TextStyle(
          color: Colors.red,
          fontSize: 11,
        ),
      ),),
                 ElevatedButton(
                  onPressed: onchanged,style: ElevatedButton.styleFrom(
                  backgroundColor: maincolor, // blue background color
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),  
                ),
                child:Text(continueText,style:  const TextStyle(color: Colors.white,fontSize: 11),),)
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsOption extends StatelessWidget {
  final  String icon;
  final String title;
  final VoidCallback onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: ListTile(
        leading: SvgPicture.asset(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
