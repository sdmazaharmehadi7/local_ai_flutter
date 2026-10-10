import 'package:flutter/material.dart';
import '../models/local_model.dart';

class ModelState extends ChangeNotifier {
  final List<LocalModel> _models = [
    const LocalModel(
      id: 'qwen-2.5-1.5b-q4',
      name: 'Qwen 2.5 1.5B Instruct',
      family: 'Qwen',
      parameterSize: '1.5B',
      quantization: 'Q4_K_M',
      diskSizeGb: 1.1,
      estimatedRamGb: 1.8,
      description:
          'Fast, highly capable compact model. Excellent for general reasoning, coding assistance, and multi-turn chat.',
      filename: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
      downloadStatus: ModelDownloadStatus.notDownloaded,
      loadStatus: ModelLoadStatus.unloaded,
    ),
    const LocalModel(
      id: 'llama-3.2-1b-q4',
      name: 'Llama 3.2 1B Instruct',
      family: 'Llama',
      parameterSize: '1B',
      quantization: 'Q4_K_M',
      diskSizeGb: 0.8,
      estimatedRamGb: 1.4,
      description:
          'Ultra-compact mobile-friendly model optimized for low-latency tasks and low-RAM environments.',
      filename: 'llama-3.2-1b-instruct-q4_k_m.gguf',
      downloadStatus: ModelDownloadStatus.notDownloaded,
      loadStatus: ModelLoadStatus.unloaded,
    ),
    const LocalModel(
      id: 'llama-3.2-3b-q4',
      name: 'Llama 3.2 3B Instruct',
      family: 'Llama',
      parameterSize: '3B',
      quantization: 'Q4_K_M',
      diskSizeGb: 2.0,
      estimatedRamGb: 3.2,
      description:
          'Strongest compact model for desktop and higher-tier devices. Enhanced instruction following and structured output.',
      filename: 'llama-3.2-3b-instruct-q4_k_m.gguf',
      downloadStatus: ModelDownloadStatus.notDownloaded,
      loadStatus: ModelLoadStatus.unloaded,
    ),
    const LocalModel(
      id: 'smollm2-1.7b-q4',
      name: 'SmolLM2 1.7B Instruct',
      family: 'SmolLM',
      parameterSize: '1.7B',
      quantization: 'Q4_K_M',
      diskSizeGb: 1.0,
      estimatedRamGb: 1.7,
      description:
          'Data-curated small language model by Hugging Face with balanced speed and reasoning efficiency.',
      filename: 'smollm2-1.7b-instruct-q4_k_m.gguf',
      downloadStatus: ModelDownloadStatus.notDownloaded,
      loadStatus: ModelLoadStatus.unloaded,
    ),
  ];

  String? _activeModelId;

  List<LocalModel> get models => List.unmodifiable(_models);

  LocalModel? get activeModel {
    if (_activeModelId == null) return null;
    return _models.where((m) => m.id == _activeModelId).firstOrNull;
  }

  bool get hasLoadedModel => activeModel != null && activeModel!.loadStatus == ModelLoadStatus.loaded;
}
