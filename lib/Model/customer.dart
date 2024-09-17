
class CustomerModel {
  String? userId;
  String? userName;
  String? deptname;
  String? phone;
  String? email;
  String? address; // Added this field for address
  String? pincode; // Added this field for pincode
  String? loginPassword;
  String? status;
  String? role;
  String? createdByUser;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? roleid;


  CustomerModel({

    this.userId,
    this.userName,
    this.deptname,
    this.phone,
    this.email,
    this.address,
    this.pincode,
    this.loginPassword,
    this.status,
    this.role,
    this.createdByUser,
    this.createdAt,
    this.updatedAt,
    this.roleid,
  
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
       
        userId: json["user_id"],
        userName: json["user_name"],
        phone: json["phone"],
        deptname: json['dept_name'],
        email: json["email"],
        address: json["address"], 
        pincode: json["pincode"], 
        loginPassword: json["login_password"],
        status: json["status"],
        role: json["role"],
        createdByUser: json["created_by_user"],
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
         roleid: json["role_id"],
      );

  Map<String, dynamic> toJson() => {
        
        "user_id": userId,
        "user_name": userName,
        "dept_name": deptname,
        "phone": phone,
        "email": email,
        "address": address,
        "pincode": pincode,
        "login_password": loginPassword,
        "status": status,
        "created_by_user": createdByUser,
        "role": role,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "role_id": roleid,
      };
}
