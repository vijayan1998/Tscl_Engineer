class SimilarRequest {
  final String id;
  final String grievanceId;
  String status;
  final String createdAt;
  final String complaindisc;
  final String deptname;

  SimilarRequest({
    required this.id,
    required this.grievanceId,
    required this.status,
    required this.createdAt,
    required this.complaindisc,
    required this.deptname
  });

  factory SimilarRequest.fromJson(Map<String, dynamic> json) {
    return SimilarRequest(
      id: json['_id'] ?? '',
      grievanceId: json['grievance_id'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      complaindisc: json['complaint_details'] ?? '',
      deptname: json['dept_name'] ?? '',
    );
  }
}
