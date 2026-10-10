import 'package:flutter/material.dart';
import '../../../models/local_model.dart';
import '../../common/status_badge.dart';

class ModelCard extends StatelessWidget {
  final LocalModel model;
  final VoidCallback? onInfoTap;

  const ModelCard({
    super.key,
    required this.model,
    this.onInfoTap,
  });

  void _showPendingDialog(BuildContext context, String actionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName: Coming in Phase 2'),
        content: Text(
          'Model downloading, verification, and llama.cpp native engine loading are '
          'part of the upcoming inference engine integration phase.\n\n'
          'Target model: ${model.name}\n'
          'Disk file: ${model.filename}\n'
          'Estimated RAM: ${model.estimatedRamGb} GB',
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
                      Text(
                        model.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
                  icon: isDownloaded ? Icons.check_circle_outline : Icons.cloud_outlined,
                  label: isDownloaded ? 'Downloaded' : 'Not Downloaded',
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
                OutlinedButton.icon(
                  onPressed: () => _showPendingDialog(context, 'Model Download'),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Download [Phase 2]'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _showPendingDialog(context, 'Engine Loading'),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Load [Phase 2]'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
