import 'package:get/get.dart';
import 'package:trichy_iccc_engineer/Model/customer.dart';
import 'package:trichy_iccc_engineer/User%20preferences/user_prefernces.dart';


class CustomerCurrentUser  extends GetxController {
  
final Rx<CustomerModel> customerUser = CustomerModel(userId: '', userName: '', phone: '',deptname: '',role: '').obs;

  CustomerModel get customer => customerUser.value;
  
  

  getUserInfo() async
  {
    CustomerModel? getUserInfoFromLocalStorage = await RememberUserPrefs.readUser();
      customerUser.value = getUserInfoFromLocalStorage!;

  }     
  
}

