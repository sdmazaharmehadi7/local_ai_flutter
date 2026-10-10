enum MessageRole {
  user,
  assistant,
  system,
}

enum MessageStatus {
  sent,
  generating,
  error,
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final String? errorMessage;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.errorMessage,
  });

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    MessageStatus? status,
    String? errorMessage,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        if (errorMessage != null) 'errorMessage': errorMessage,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String?;
    var resolvedStatus = MessageStatus.values.firstWhere(
      (s) => s.name == rawStatus,
      orElse: () => MessageStatus.sent,
    );

    // If a message was saved mid-generation and restored across app restart,
    // normalize it to sent so it doesn't show an interrupted perpetual loading state.
    if (resolvedStatus == MessageStatus.generating) {
      resolvedStatus = MessageStatus.sent;
    }

    return ChatMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      status: resolvedStatus,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
