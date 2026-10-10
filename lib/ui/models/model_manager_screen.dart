import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import 'widgets/model_card.dart';

class ModelManagerScreen extends StatelessWidget {
  const ModelManagerScreen({super.key});

  void _showImportPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual GGUF Import: Coming Soon'),
        content: const Text(
          'In Phase 2, you will be able to pick any existing .gguf file from your '
          'device storage and run inference with it directly without downloading.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modelState = AppScope.modelOf(context);
    final models = modelState.models;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Manager'),
        actions: [
          TextButton.icon(
            onPressed: () => _showImportPendingDialog(context),
            icon: const Icon(Icons.file_open_outlined, size: 16),
            label: const Text('Import .gguf [Phase 2]'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline Model Registry',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All weights are stored locally on your device storage. Sovereign AI performs zero cloud queries, zero tracking, and zero API calls.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recommended Quantized Models',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${models.length} Available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              ...models.map((model) => ModelCard(model: model)),
            ],
          ),
        ),
      ),
    );
  }
}
