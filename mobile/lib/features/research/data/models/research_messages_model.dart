enum ContentType {
  text,
  image,
  file,
  audioFile;

  String toJson() => name;

  static ContentType fromJson(String json) {
    switch (json) {
      case 'text':
        return ContentType.text;
      case 'image':
        return ContentType.image;
      case 'file':
        return ContentType.file;
      case 'audio_file':
        return ContentType.audioFile;
      default:
        return ContentType.text;
    }
  }
}

enum MessageContentType {
  sent,
  received;

  String toJson() => name;

  static MessageContentType fromJson(String json) {
    switch (json) {
      case 'sent':
        return MessageContentType.sent;
      case 'received':
        return MessageContentType.received;
      default:
        return MessageContentType.sent;
    }
  }
}

class ResearchMessageModel {
  final int id;
  final DateTime createdAt;
  final String? content;
  final ContentType? contentType;
  final MessageContentType? messageType;
  final String? researcherId;
  final String? conversationId;

  ResearchMessageModel({
    required this.id,
    required this.createdAt,
    this.content,
    this.contentType,
    this.messageType,
    this.researcherId,
    this.conversationId,
  });

  factory ResearchMessageModel.fromJson(Map<String, dynamic> json) {
    return ResearchMessageModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      content: json['content'] as String?,
      contentType: json['content_type'] != null
          ? ContentType.fromJson(json['content_type'] as String)
          : null,
      messageType: json['message_type'] != null
          ? MessageContentType.fromJson(json['message_type'] as String)
          : null,
      researcherId: json['researcher_id'] as String?,
      conversationId: json['conversation_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'content': content,
      'content_type': contentType?.toJson(),
      'message_type': messageType?.toJson(),
      'researcher_id': researcherId,
      'conversation_id': conversationId,
    };
  }

  ResearchMessageModel copyWith({
    int? id,
    DateTime? createdAt,
    String? content,
    ContentType? contentType,
    MessageContentType? messageType,
    String? researcherId,
    String? conversationId,
  }) {
    return ResearchMessageModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      messageType: messageType ?? this.messageType,
      researcherId: researcherId ?? this.researcherId,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
