import 'package:flutter/material.dart';

import '../../../models/local_model.dart';
import '../../common/status_badge.dart';

class ModelCard extends StatelessWidget {
  final LocalModel model;
  final VoidCallback? onLoad;
  final VoidCallback? onUnload;
  final VoidCallback? onPickLocal;
  final VoidCallback? onDownload;
  final VoidCallback? onPauseDownload;
  final VoidCallback? onResumeDownload;
  final VoidCallback? onCancelDownload;
  final VoidCallback? onDelete;
  final bool isLoading;

  const ModelCard({
    super.key,
    required this.model,
    this.onLoad,
    this.onUnload,
    this.onPickLocal,
    this.onDownload,
    this.onPauseDownload,
    this.onResumeDownload,
    this.onCancelDownload,
    this.onDelete,
    this.isLoading = false,
  });

  String _formatSpeed(double bytesPerSec) {
    if (bytesPerSec <= 0) return '';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s';
  }

  String _formatSize(int downloaded, int total) {
    final downMb = downloaded / (1024 * 1024);
    if (total > 0) {
      final totalMb = total / (1024 * 1024);
      if (totalMb >= 1024) {
        return '${(downMb / 1024).toStringAsFixed(2)} / ${(totalMb / 1024).toStringAsFixed(2)} GB';
      }
      return '${downMb.toStringAsFixed(1)} / ${totalMb.toStringAsFixed(1)} MB';
    }
    return '${downMb.toStringAsFixed(1)} MB';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Model Weights?'),
        content: Text(
          'Are you sure you want to delete the file for "${model.name}" from your local storage? '
          'You will need to download or re-import the .gguf file to use it again.',
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
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDownloaded = model.downloadStatus == ModelDownloadStatus.downloaded;
    final isDownloading =
        model.downloadStatus == ModelDownloadStatus.downloading;
    final isPaused = model.downloadStatus == ModelDownloadStatus.paused;
    final isError = model.downloadStatus == ModelDownloadStatus.error;
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
                            const StatusBadge(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      label: model.quantization,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: model.license,
                      color: theme.colorScheme.outline,
                      isOutlined: true,
                    ),
                  ],
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
                  icon: Icons.person_outline,
                  label: model.publisher,
                  color: theme.colorScheme.outline,
                  isOutlined: true,
                ),
                StatusBadge(
                  icon: Icons.speed,
                  label: 'Min ${model.minRamGb} GB RAM',
                  color: theme.colorScheme.outline,
                  isOutlined: true,
                ),
                if (isDownloaded)
                  const StatusBadge(
                    icon: Icons.check_circle_outline,
                    label: 'Downloaded',
                    color: Colors.green,
                  )
                else if (isDownloading)
                  StatusBadge(
                    icon: Icons.downloading,
                    label: 'Downloading',
                    color: theme.colorScheme.primary,
                  )
                else if (isPaused)
                  const StatusBadge(
                    icon: Icons.pause_circle_outline,
                    label: 'Paused',
                    color: Colors.orange,
                  )
                else if (isError)
                  StatusBadge(
                    icon: Icons.error_outline,
                    label: 'Download Failed',
                    color: theme.colorScheme.error,
                  )
                else
                  StatusBadge(
                    icon: Icons.cloud_download_outlined,
                    label: 'Not Downloaded',
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
            if (isDownloading || isPaused) ...[
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPaused
                            ? 'Paused (${(model.downloadProgress * 100).toStringAsFixed(1)}%)'
                            : '${(model.downloadProgress * 100).toStringAsFixed(1)}% '
                                  '(${_formatSize(model.downloadedBytes, model.totalBytes)})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isDownloading && model.downloadSpeedBytesPerSec > 0)
                        Text(
                          _formatSpeed(model.downloadSpeedBytesPerSec),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: model.downloadProgress > 0
                        ? model.downloadProgress
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
            if (isError && model.downloadError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        model.downloadError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDownloading) ...[
                  OutlinedButton.icon(
                    onPressed: onPauseDownload,
                    icon: const Icon(Icons.pause, size: 16),
                    label: const Text('Pause'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onCancelDownload,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ] else if (isPaused) ...[
                  FilledButton.tonalIcon(
                    onPressed: onResumeDownload,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Resume'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onCancelDownload,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ] else if (isError) ...[
                  FilledButton.tonalIcon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry Download'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onPickLocal,
                    icon: const Icon(Icons.folder_open, size: 16),
                    label: const Text('Import Local'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ] else if (!isDownloaded) ...[
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onPickLocal,
                    icon: const Icon(Icons.file_open_outlined, size: 16),
                    label: const Text('Import .gguf'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (model.downloadUrl != null) ...[
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: isLoading ? null : onDownload,
                      icon: const Icon(Icons.download, size: 16),
                      label: Text('Download (${model.diskSizeGb} GB)'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ] else ...[
                  // Downloaded / Imported
                  IconButton(
                    tooltip: 'Delete local model file',
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: isLoading ? null : () => _confirmDelete(context),
                  ),
                  const Spacer(),
                  if (!isLoaded) ...[
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
