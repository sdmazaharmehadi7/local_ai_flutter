import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onStop;
  final bool isGenerating;
  final bool hasModelLoaded;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onStop,
    this.isGenerating = false,
    this.hasModelLoaded = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (hasTextNow != _hasText) {
        setState(() {
          _hasText = hasTextNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isGenerating) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.enter): () {
                  if (_hasText && !widget.isGenerating) {
                    _handleSend();
                  }
                },
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hasModelLoaded
                              ? 'Message Sovereign AI...'
                              : 'Message (Inference engine offline)...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 14.5,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: IconButton.filled(
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: widget.isGenerating
                                ? theme.colorScheme.error
                                : (_hasText
                                      ? theme.colorScheme.primary
                                      : (isDark
                                            ? const Color(0xFF3F3F46)
                                            : const Color(0xFFE4E4E7))),
                            foregroundColor: widget.isGenerating
                                ? Colors.white
                                : (_hasText
                                      ? Colors.white
                                      : (isDark
                                            ? const Color(0xFFA1A1AA)
                                            : const Color(0xFF71717A))),
                            elevation: 0,
                          ),
                          onPressed: widget.isGenerating
                              ? widget.onStop
                              : (_hasText ? _handleSend : null),
                          tooltip: widget.isGenerating
                              ? 'Stop generation'
                              : (_hasText ? 'Send message' : 'Type to send'),
                          icon: widget.isGenerating
                              ? const Icon(Icons.stop_rounded, size: 18)
                              : const Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
