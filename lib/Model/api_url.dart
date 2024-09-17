// ignore_for_file: prefer_interpolation_to_compose_strings

 
 //String get url => 'http://10.64.4.222:4000/';

 String get url => 'http://13.48.10.96:4000/';

//String get url => 'http://192.168.173.177:4000/';


class ApiUrl {
  static String getuserid(String userId) => url + "user/getbyid?user_id=$userId";
  static String changepass(String phone) => url + "user/userchangepassword?phone=$phone";
  static String forgetpass(String phone) => url + "user/userforgotpassword?phone=$phone";
  static String deleteacc(String userId) => url + "user/delete?user_id=$userId";
  static String editprof(String userId) => url + "user/update?user_id=$userId";
  static String imgget(String grievId) => url + "new-grievance-attachment/getattachments?grievance_id=$grievId";
  static String getfile(String filename) => url + "new-grievance-attachment/file/$filename";
  static String get grievanceLog => url + "grievance-log/post";
  static String grievlogget(String grievId) => url + "grievance-log/getbyid?grievance_id=$grievId";
  static String get loginweb => url + "user/loginweb";
  static String get similarrequest => url + "new-grievance/filter";
  static String get escalation => url + "grievance-escalation/getbydeptrole";
  static String get status => url + "status/get";
  static String get depart => url + "department/get";
  static String  grievancedata(String grievId) => url + "new-grievance/getbyid?grievance_id=$grievId";
  static String updatestatus(String grievId) => url + "new-grievance/updatestatus?grievance_id=$grievId";
  static String get complainttype => url + "complainttype/get";
  static String getuserdata(String userId) => url + "new-grievance/getbyassign?assign_user=$userId";
  static String get replycomplain => url + "grievance-worksheet/post";
  static String get replyComplainAttach => url + "grievance-worksheet-attachment/post";
  static String grievanceattchment(String grievanceId) => url + "grievance-worksheet-attachment/getattachments?grievance_id=$grievanceId";
  static String grievanceWorksheet(String filename) => url +"grievance-worksheet-attachment/file/$filename";

}

