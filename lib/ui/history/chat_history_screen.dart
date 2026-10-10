import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import '../common/empty_state_view.dart';

class ChatHistoryScreen extends StatelessWidget {
  final VoidCallback onNavigateToChat;

  const ChatHistoryScreen({
    super.key,
    required this.onNavigateToChat,
  });

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text(
          'This will delete all conversations stored on your local device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              AppScope.chatOf(context).clearAllSessions();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = AppScope.chatOf(context);
    final sessions = chatState.sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          if (sessions.isNotEmpty)
            IconButton(
              tooltip: 'Clear All',
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              onPressed: () => _confirmClearAll(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: sessions.isEmpty
          ? EmptyStateView(
              icon: Icons.history_rounded,
              title: 'No Conversations Yet',
              description:
                  'Your local chat logs will appear here. No data is ever uploaded or synced to external servers.',
              action: FilledButton.tonalIcon(
                onPressed: () {
                  chatState.createNewChat();
                  onNavigateToChat();
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Start New Conversation'),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final isCurrent = session.id == chatState.activeSessionId;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                        ),
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${session.messages.length} messages • ${_formatDate(session.updatedAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          tooltip: 'Delete',
                          onPressed: () {
                            chatState.deleteSession(session.id);
                          },
                        ),
                        onTap: () {
                          chatState.selectSession(session.id);
                          onNavigateToChat();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
