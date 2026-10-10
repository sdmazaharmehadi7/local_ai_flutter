import 'package:flutter/material.dart';
import '../../../models/local_model.dart';
import '../../common/status_badge.dart';

class ModelCard extends StatelessWidget {
  final LocalModel model;
  final VoidCallback? onLoad;
  final VoidCallback? onUnload;
  final VoidCallback? onPickLocal;
  final bool isLoading;

  const ModelCard({
    super.key,
    required this.model,
    this.onLoad,
    this.onUnload,
    this.onPickLocal,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDownloaded =
        model.downloadStatus == ModelDownloadStatus.downloaded;
    final isLoaded = model.loadStatus == ModelLoadStatus.loaded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              model.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isLoaded) ...[
                            const SizedBox(width: 8),
                            StatusBadge(
                              icon: Icons.check_circle,
                              label: 'Active Model',
                              color: Colors.green,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: model.quantization,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                StatusBadge(
                  icon: Icons.pie_chart_outline,
                  label: '${model.diskSizeGb} GB Disk',
                  color: theme.colorScheme.outline,
                  isOutlined: true,
                ),
                StatusBadge(
                  icon: Icons.memory_outlined,
                  label: '~${model.estimatedRamGb} GB RAM',
                  color: theme.colorScheme.outline,
                  isOutlined: true,
                ),
                StatusBadge(
                  icon: isDownloaded ? Icons.check_circle_outline : Icons.insert_drive_file_outlined,
                  label: isDownloaded ? 'File Located' : 'Local File Required',
                  color: isDownloaded ? Colors.green : theme.colorScheme.outline,
                ),
                StatusBadge(
                  icon: isLoaded ? Icons.play_circle_outline : Icons.stop_circle_outlined,
                  label: isLoaded ? 'Loaded in RAM' : 'Unloaded',
                  color: isLoaded ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isLoaded && model.localPath == null)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onPickLocal,
                    icon: const Icon(Icons.file_open_outlined, size: 16),
                    label: const Text('Locate .gguf File'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (!isLoaded && model.localPath != null) ...[
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onPickLocal,
                    icon: const Icon(Icons.folder_open_outlined, size: 16),
                    label: const Text('Change File'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: isLoading ? null : onLoad,
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text('Load into RAM'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                if (isLoaded)
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: isLoading ? null : onUnload,
                    icon: const Icon(Icons.stop_circle_outlined, size: 16),
                    label: const Text('Unload from Memory'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
