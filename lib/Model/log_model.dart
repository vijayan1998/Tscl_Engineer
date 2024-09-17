class LogDetail {
  final String id;
  final String logMessage;
  final String createdAt;

  LogDetail({
    required this.id,
    required this.logMessage,
    required this.createdAt,
  });

  factory LogDetail.fromJson(Map<String, dynamic> json) {
    return LogDetail(
      id: json['_id'],
      logMessage: json['log_details'],
      createdAt: json['createdAt'],
    );
  }
}