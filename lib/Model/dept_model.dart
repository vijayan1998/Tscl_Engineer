class DeptModel {
    DeptModel({
        required this.deptId,
        required this.deptName,
        required this.orgName,
        required this.status,
        required this.createdByUser,
    });

    final String deptId;
    final String deptName;
    final String orgName;
    final String status;
    final String createdByUser;

    factory DeptModel.fromJson(Map<String, dynamic> json){ 
        return DeptModel(
            deptId: json["dept_id"] ?? "",
            deptName: json["dept_name"] ?? "",
            orgName: json["org_name"] ?? "",
            status: json["status"] ?? "",
            createdByUser: json["created_by_user"] ?? "",
        );
    }

}
