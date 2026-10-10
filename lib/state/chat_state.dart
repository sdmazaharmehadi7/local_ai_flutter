import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatState extends ChangeNotifier {
  final List<ChatSession> _sessions = [];
  String? _activeSessionId;
  bool _isGenerating = false;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isGenerating => _isGenerating;
  String? get activeSessionId => _activeSessionId;

  void setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  ChatSession? get activeSession {
    if (_activeSessionId == null) return null;
    return _sessions.where((s) => s.id == _activeSessionId).firstOrNull;
  }

  void createNewChat({String? initialTitle}) {
    final now = DateTime.now();
    final newSession = ChatSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      title: initialTitle ?? 'New Conversation',
      createdAt: now,
      updatedAt: now,
      messages: [],
    );
    _sessions.insert(0, newSession);
    _activeSessionId = newSession.id;
    notifyListeners();
  }

  void selectSession(String sessionId) {
    if (_activeSessionId != sessionId) {
      _activeSessionId = sessionId;
      notifyListeners();
    }
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.isNotEmpty ? _sessions.first.id : null;
    }
    notifyListeners();
  }

  void clearAllSessions() {
    _sessions.clear();
    _activeSessionId = null;
    notifyListeners();
  }

  /// Sends a user message. Because local inference engine is not wired yet,
  /// this records the user message and appends an explicit system status notice
  /// rather than generating simulated or fake AI replies.
  void submitUserMessage(String content, {required bool hasModelLoaded}) {
    if (content.trim().isEmpty) return;

    if (activeSession == null) {
      createNewChat(initialTitle: _deriveTitle(content));
    }

    final now = DateTime.now();
    final currentSession = activeSession!;
    final userMessage = ChatMessage(
      id: 'msg_user_${now.millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: content.trim(),
      timestamp: now,
      status: MessageStatus.sent,
    );

    final updatedMessages = List<ChatMessage>.from(currentSession.messages)..add(userMessage);

    // If session title was generic, update with first message excerpt
    String newTitle = currentSession.title;
    if (currentSession.messages.isEmpty && currentSession.title == 'New Conversation') {
      newTitle = _deriveTitle(content);
    }

    // Append system message informing the user about the engine status
    if (!hasModelLoaded) {
      final systemNotice = ChatMessage(
        id: 'msg_sys_${now.millisecondsSinceEpoch + 1}',
        role: MessageRole.system,
        content:
            'Inference Engine Offline: No local GGUF model is loaded into memory. Download and load a model from the Model Manager to generate offline responses.',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
      updatedMessages.add(systemNotice);
    }

    final updatedSession = currentSession.copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
      messages: updatedMessages,
    );

    final index = _sessions.indexWhere((s) => s.id == currentSession.id);
    if (index != -1) {
      _sessions[index] = updatedSession;
    }

    notifyListeners();
  }

  String _deriveTitle(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= 32) return clean;
    return '${clean.substring(0, 32)}...';
  }
}
