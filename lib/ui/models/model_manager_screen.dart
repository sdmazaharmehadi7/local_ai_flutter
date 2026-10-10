import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import 'widgets/model_card.dart';

class ModelManagerScreen extends StatelessWidget {
  const ModelManagerScreen({super.key});

  Future<void> _pickAndLoadFile(BuildContext context) async {
    final theme = Theme.of(context);
    final modelState = AppScope.modelOf(context);
    final settingsState = AppScope.settingsOf(context);

    if (kIsWeb) {
      _showDialog(
        context,
        title: 'Platform Unsupported',
        message:
            'Native GGUF local model inference is not supported in the web browser environment. '
            'Please run the desktop (macOS, Windows, Linux) or mobile (Android) build.',
      );
      return;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result.isEmpty) return;

      final path = result.first.path;
      if (path == null) {
        if (context.mounted) {
          _showDialog(
            context,
            title: 'File Selection Error',
            message: 'Unable to access the chosen file path on this platform.',
          );
        }
        return;
      }

      if (!path.toLowerCase().endsWith('.gguf')) {
        if (context.mounted) {
          _showDialog(
            context,
            title: 'Invalid File Format',
            message:
                'Only .gguf quantized model files are supported. Please select a valid .gguf model.',
          );
        }
        return;
      }

      final success = await modelState.loadLocalModelFile(
        path,
        contextWindow: settingsState.generationSettings.contextWindow,
        useGpu: settingsState.generationSettings.useGpuAcceleration,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.colorScheme.primaryContainer,
            content: Text(
              'Model "${modelState.activeModel?.name}" loaded successfully into memory.',
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showDialog(
          context,
          title: 'Import Error',
          message: 'An error occurred while picking the model file: $e',
        );
      }
    }
  }

  void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    final settingsState = AppScope.settingsOf(context);
    final models = modelState.models;
    final activeModel = modelState.activeModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Manager'),
        actions: [
          FilledButton.icon(
            onPressed: modelState.isLoading ? null : () => _pickAndLoadFile(context),
            icon: const Icon(Icons.file_open, size: 16),
            label: const Text('Select .gguf File'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (modelState.isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          modelState.loadingMessage ?? 'Processing model...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (modelState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          modelState.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: modelState.clearError,
                      ),
                    ],
                  ),
                ),
              ],
              if (activeModel != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.memory, color: Colors.green, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active in RAM: ${activeModel.name}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Context: ${settingsState.generationSettings.contextWindow} tokens • File: ${activeModel.filename}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: modelState.isLoading
                            ? null
                            : () => modelState.unloadActiveModel(),
                        child: const Text('Unload'),
                      ),
                    ],
                  ),
                ),
              ],
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
                          Icons.shield_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Strict On-Device Architecture',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sovereign AI never automatically downloads files or connects to cloud endpoints. '
                      'To run inference, locate or select a .gguf model file on your local storage. '
                      'The model runs entirely in-memory using your local CPU/GPU.',
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
                      'Model Registry & Presets',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${models.length} Entries',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              ...models.map((model) {
                return ModelCard(
                  model: model,
                  isLoading: modelState.isLoading,
                  onPickLocal: () => _pickAndLoadFile(context),
                  onLoad: model.localPath != null
                      ? () => modelState.loadLocalModelFile(
                            model.localPath!,
                            contextWindow:
                                settingsState.generationSettings.contextWindow,
                            useGpu: settingsState
                                .generationSettings.useGpuAcceleration,
                          )
                      : null,
                  onUnload: () => modelState.unloadActiveModel(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
