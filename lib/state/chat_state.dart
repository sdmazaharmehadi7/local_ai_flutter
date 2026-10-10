import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/generation_settings.dart';
import '../services/inference_service.dart';
import '../services/storage_service.dart';

class ChatState extends ChangeNotifier {
  static int _idCounter = 0;
  final IStorageService? storageService;
  final List<ChatSession> _sessions = [];
  String? _activeSessionId;
  bool _isGenerating = false;
  StreamSubscription<String>? _generationSubscription;
  Timer? _debounceTimer;
  Completer<void>? _generationCompleter;

  ChatState({this.storageService});

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isGenerating => _isGenerating;
  String? get activeSessionId => _activeSessionId;

  ChatSession? get activeSession {
    if (_activeSessionId == null) return null;
    return _sessions.where((s) => s.id == _activeSessionId).firstOrNull;
  }

  Future<void> init() async {
    if (storageService == null) return;
    try {
      final stored = await storageService!.loadConversations();
      _sessions.clear();
      _sessions.addAll(stored.sessions);

      if (stored.activeSessionId != null &&
          _sessions.any((s) => s.id == stored.activeSessionId)) {
        _activeSessionId = stored.activeSessionId;
      } else if (_sessions.isNotEmpty) {
        _activeSessionId = _sessions.first.id;
      } else {
        _activeSessionId = null;
      }
      notifyListeners();
    } catch (_) {
      // Gracefully continue with in-memory sessions on error
    }
  }

  void createNewChat({
    String? initialTitle,
    String? modelId,
    String? activeModelName,
  }) {
    final now = DateTime.now();
    final newSession = ChatSession(
      id: 'session_${now.microsecondsSinceEpoch}_${++_idCounter}',
      title: initialTitle ?? 'New Conversation',
      createdAt: now,
      updatedAt: now,
      modelId: modelId,
      activeModelName: activeModelName,
      messages: [],
    );
    _sessions.insert(0, newSession);
    _activeSessionId = newSession.id;
    notifyListeners();
    _persist();
  }

  void selectSession(String sessionId) {
    if (_activeSessionId != sessionId) {
      _activeSessionId = sessionId;
      notifyListeners();
      _persist();
    }
  }

  void renameSession(String sessionId, String newTitle) {
    final cleanTitle = newTitle.trim();
    if (cleanTitle.isEmpty) return;

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final updated = _sessions[index].copyWith(
        title: cleanTitle,
        updatedAt: DateTime.now(),
      );
      _sessions[index] = updated;
      notifyListeners();
      _persist();
    }
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.isNotEmpty ? _sessions.first.id : null;
    }
    notifyListeners();
    _persist();
  }

  void clearAllSessions() {
    _sessions.clear();
    _activeSessionId = null;
    notifyListeners();
    storageService?.clearAllChatData();
  }

  Future<void> sendMessage(
    String content, {
    required IInferenceService inferenceService,
    required GenerationSettings settings,
  }) async {
    final cleanContent = content.trim();
    if (cleanContent.isEmpty ||
        _isGenerating ||
        inferenceService.isGenerating) {
      return;
    }

    if (activeSession == null) {
      createNewChat(
        initialTitle: _deriveTitle(cleanContent),
        modelId: inferenceService.currentModelName,
        activeModelName: inferenceService.currentModelName,
      );
    }

    final currentSession = activeSession!;
    final now = DateTime.now();

    // 1. Append user message
    final userMessage = ChatMessage(
      id: 'msg_user_${now.microsecondsSinceEpoch}_${++_idCounter}',
      role: MessageRole.user,
      content: cleanContent,
      timestamp: now,
      status: MessageStatus.sent,
    );

    final updatedMessages = List<ChatMessage>.from(currentSession.messages)
      ..add(userMessage);

    String newTitle = currentSession.title;
    if (currentSession.messages.isEmpty &&
        currentSession.title == 'New Conversation') {
      newTitle = _deriveTitle(cleanContent);
    }

    // 2. If model is NOT loaded, add an honest system notice without fake AI response
    if (!inferenceService.isLoaded) {
      final systemNotice = ChatMessage(
        id: 'msg_sys_${now.microsecondsSinceEpoch}_${++_idCounter}',
        role: MessageRole.system,
        content:
            'Inference Engine Offline: No local GGUF model is loaded into memory. Load a model in the Model Manager to generate real offline responses.',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
      updatedMessages.add(systemNotice);

      _updateSession(
        currentSession.copyWith(
          title: newTitle,
          updatedAt: DateTime.now(),
          messages: updatedMessages,
        ),
      );
      _persist();
      return;
    }

    // 3. Model IS loaded: Start real streaming inference
    final assistantMessageId = 'msg_ast_${now.microsecondsSinceEpoch}_${++_idCounter}';
    final assistantPlaceholder = ChatMessage(
      id: assistantMessageId,
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      status: MessageStatus.generating,
    );

    updatedMessages.add(assistantPlaceholder);
    _updateSession(
      currentSession.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
        modelId: currentSession.modelId ?? inferenceService.currentModelName,
        activeModelName: currentSession.activeModelName ??
            inferenceService.currentModelName,
        messages: updatedMessages,
      ),
    );
    _persist();

    _isGenerating = true;
    notifyListeners();

    final buffer = StringBuffer();
    final completer = Completer<void>();
    _generationCompleter = completer;

    try {
      final tokenStream = inferenceService.generate(
        messages: updatedMessages.sublist(0, updatedMessages.length - 1),
        settings: settings,
      );

      _generationSubscription = tokenStream.listen(
        (token) {
          buffer.write(token);
          _updateAssistantContent(
            assistantMessageId,
            buffer.toString(),
            status: MessageStatus.generating,
          );
          // Debounce persistence during generation to avoid excessive disk writes
          _scheduleDebouncedPersistence();
        },
        onError: (Object error) {
          _cancelDebouncedPersistence();
          final errorMsg = error is InferenceException
              ? error.message
              : 'Inference encountered an error during generation.';
          _updateAssistantContent(
            assistantMessageId,
            buffer.isNotEmpty
                ? '${buffer.toString()}\n\n[Inference interrupted: $errorMsg]'
                : '[Error: $errorMsg]',
            status: MessageStatus.error,
            errorMessage: errorMsg,
          );
          _persist();
          if (!completer.isCompleted) completer.complete();
          _generationCompleter = null;
        },
        onDone: () {
          _cancelDebouncedPersistence();
          _updateAssistantContent(
            assistantMessageId,
            buffer.toString().trim(),
            status: MessageStatus.sent,
          );
          _persist();
          if (!completer.isCompleted) completer.complete();
          _generationCompleter = null;
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      _cancelDebouncedPersistence();
      final errorMsg = e is InferenceException
          ? e.message
          : 'Failed to generate response on local hardware.';
      _updateAssistantContent(
        assistantMessageId,
        '[Error: $errorMsg]',
        status: MessageStatus.error,
        errorMessage: errorMsg,
      );
      _persist();
      if (!completer.isCompleted) completer.complete();
      _generationCompleter = null;
    } finally {
      _isGenerating = false;
      _generationSubscription = null;
      _generationCompleter = null;
      notifyListeners();
    }
  }

  Future<void> stopGeneration({required IInferenceService inferenceService}) async {
    if (!_isGenerating) return;

    await inferenceService.stopGeneration();
    await _generationSubscription?.cancel();
    _generationSubscription = null;
    if (!(_generationCompleter?.isCompleted ?? true)) {
      _generationCompleter?.complete();
    }
    _generationCompleter = null;
    _cancelDebouncedPersistence();
    _isGenerating = false;

    // Mark active generating message as stopped
    if (activeSession != null) {
      final messages = List<ChatMessage>.from(activeSession!.messages);
      final lastIdx =
          messages.indexWhere((m) => m.status == MessageStatus.generating);
      if (lastIdx != -1) {
        final lastMsg = messages[lastIdx];
        messages[lastIdx] = lastMsg.copyWith(
          content: lastMsg.content.trim().isNotEmpty
              ? '${lastMsg.content.trim()} [Stopped]'
              : '[Generation stopped by user]',
          status: MessageStatus.sent,
        );
        _updateSession(activeSession!.copyWith(messages: messages));
      }
    }

    notifyListeners();
    _persist();
  }

  void _updateAssistantContent(
    String messageId,
    String content, {
    required MessageStatus status,
    String? errorMessage,
  }) {
    if (activeSession == null) return;
    final messages = List<ChatMessage>.from(activeSession!.messages);
    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(
        content: content,
        status: status,
        errorMessage: errorMessage,
      );
      _updateSession(activeSession!.copyWith(messages: messages));
    }
  }

  void _updateSession(ChatSession session) {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) {
      _sessions[idx] = session;
    }
    notifyListeners();
  }

  void _scheduleDebouncedPersistence() {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 750), () {
      _persist();
    });
  }

  void _cancelDebouncedPersistence() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void _persist() {
    storageService?.saveConversations(
      _sessions,
      activeSessionId: _activeSessionId,
    );
  }

  String _deriveTitle(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= 32) return clean;
    return '${clean.substring(0, 32)}...';
  }

  @override
  void dispose() {
    _cancelDebouncedPersistence();
    _generationSubscription?.cancel();
    if (!(_generationCompleter?.isCompleted ?? true)) {
      _generationCompleter?.complete();
    }
    _generationCompleter = null;
    super.dispose();
  }
}
