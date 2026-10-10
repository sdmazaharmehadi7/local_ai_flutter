import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import '../common/empty_state_view.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/no_model_banner.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback onOpenModelManager;

  const ChatScreen({
    super.key,
    required this.onOpenModelManager,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = AppScope.chatOf(context);
    final modelState = AppScope.modelOf(context);
    final activeSession = chatState.activeSession;
    final messages = activeSession?.messages ?? [];
    final hasModelLoaded = modelState.hasLoadedModel;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeSession?.title ?? 'Sovereign AI',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: hasModelLoaded ? Colors.green : Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasModelLoaded
                      ? '${modelState.activeModel!.name} (Loaded)'
                      : 'No Model Loaded',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New Conversation',
            icon: const Icon(Icons.add_comment_outlined, size: 20),
            onPressed: () {
              chatState.createNewChat();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (!hasModelLoaded)
            NoModelBanner(onOpenModelManager: widget.onOpenModelManager),
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context, hasModelLoaded)
                : _buildMessageList(messages, chatState.isGenerating),
          ),
          ChatInputBar(
            hasModelLoaded: hasModelLoaded,
            isGenerating: chatState.isGenerating,
            onSend: (text) {
              chatState.submitUserMessage(
                text,
                hasModelLoaded: hasModelLoaded,
              );
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasModelLoaded) {
    return EmptyStateView(
      icon: Icons.shield_outlined,
      title: 'Local & Offline Intelligence',
      description:
          'Your conversations, context, and prompts never leave this device. '
          'All computation is performed 100% locally using GGUF weights on your hardware.',
      action: !hasModelLoaded
          ? OutlinedButton.icon(
              onPressed: widget.onOpenModelManager,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Manage Local Models'),
            )
          : null,
    );
  }

  Widget _buildMessageList(List<dynamic> messages, bool isGenerating) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: messages.length + (isGenerating ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length && isGenerating) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Generating response locally...',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return MessageBubble(message: messages[index]);
          },
        ),
      ),
    );
  }
}
