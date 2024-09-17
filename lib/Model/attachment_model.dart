class AttachmentLog {
  final String id;
  final String attachment;
  final String createdAt;

  AttachmentLog({
    required this.id,
    required this.attachment,
    required this.createdAt,
  });

  factory AttachmentLog.fromJson(Map<String, dynamic> json) {
    return AttachmentLog(
      id: json['_id'],
      attachment: json['attachment'],
      createdAt: json['createdAt'],
    );
  }
}