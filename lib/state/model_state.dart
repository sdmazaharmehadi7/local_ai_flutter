import 'dart:io' show File;
import 'package:flutter/material.dart';
import '../models/local_model.dart';
import '../services/inference_service.dart';

class ModelState extends ChangeNotifier {
  final IInferenceService _inferenceService;

  final List<LocalModel> _models = [
    const LocalModel(
      id: 'smollm2-135m-q4',
      name: 'SmolLM2 135M Instruct',
      family: 'SmolLM',
      parameterSize: '135M',
      quantization: 'Q4_K_M',
      diskSizeGb: 0.1,
      estimatedRamGb: 0.25,
      description:
          'Ultra-compact test model (Apache 2.0). Ideal for instant smoke testing and low-memory validation on any device.',
      filename: 'SmolLM2-135M-Instruct-Q4_K_M.gguf',
      downloadStatus: ModelDownloadStatus.notDownloaded,
      loadStatus: ModelLoadStatus.unloaded,
    ),
    const LocalModel(
      id: 'qwen-2.5-0.5b-q4',
      name: 'Qwen 2.5 0.5B Instruct',
      family: 'Qwen',
      parameterSize: '0.5B',
      quantization: 'Q4_K_M',
      diskSizeGb: 0.39,
      estimatedRamGb: 0.7,
      description:
          'Lightweight high-efficiency model (Apache 2.0) with strong multilingual understanding and low resource footprint.',
      filename: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
      downloadStatus: ModelDownloadStatus.notDownloaded,
      loadStatus: ModelLoadStatus.unloaded,
    ),
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
  ];

  LocalModel? _activeModel;
  bool _isLoading = false;
  String? _loadingMessage;
  String? _errorMessage;

  ModelState({IInferenceService? inferenceService})
      : _inferenceService = inferenceService ?? LocalInferenceService();

  IInferenceService get inferenceService => _inferenceService;
  List<LocalModel> get models => List.unmodifiable(_models);
  LocalModel? get activeModel => _activeModel;
  bool get hasLoadedModel => _inferenceService.isLoaded;
  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> loadLocalModelFile(
    String filePath, {
    int contextWindow = 2048,
    bool useGpu = true,
  }) async {
    _isLoading = true;
    _loadingMessage = 'Loading model weights and initializing inference context...';
    _errorMessage = null;
    notifyListeners();

    try {
      await _inferenceService.loadModel(
        filePath,
        contextWindow: contextWindow,
        useGpu: useGpu,
      );

      final file = File(filePath);
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : filePath;
      final fileSizeBytes = file.existsSync() ? file.lengthSync() : 0;
      final diskSizeGb = (fileSizeBytes / (1024 * 1024 * 1024));

      // Check if matches known presets or create new custom imported entry
      final existingIndex = _models.indexWhere(
        (m) => m.filename.toLowerCase() == fileName.toLowerCase(),
      );

      if (existingIndex != -1) {
        _activeModel = _models[existingIndex].copyWith(
          downloadStatus: ModelDownloadStatus.downloaded,
          loadStatus: ModelLoadStatus.loaded,
          localPath: filePath,
        );
        _models[existingIndex] = _activeModel!;
      } else {
        _activeModel = LocalModel(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: fileName.replaceAll('.gguf', '').replaceAll('_', ' '),
          family: 'Custom GGUF',
          parameterSize: 'Unknown',
          quantization: 'GGUF',
          diskSizeGb: double.parse(diskSizeGb.toStringAsFixed(2)),
          estimatedRamGb: double.parse((diskSizeGb * 1.3).toStringAsFixed(2)),
          description: 'Imported local model file from device storage.',
          filename: fileName,
          downloadStatus: ModelDownloadStatus.downloaded,
          loadStatus: ModelLoadStatus.loaded,
          localPath: filePath,
        );
        _models.insert(0, _activeModel!);
      }

      _isLoading = false;
      _loadingMessage = null;
      notifyListeners();
      return true;
    } on InferenceException catch (e) {
      _errorMessage = e.message;
      _activeModel = null;
      _isLoading = false;
      _loadingMessage = null;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage =
          'An unexpected error occurred while loading the model: ${e.toString().split('\n').first}';
      _activeModel = null;
      _isLoading = false;
      _loadingMessage = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> unloadActiveModel() async {
    _isLoading = true;
    _loadingMessage = 'Unloading model and releasing native memory buffers...';
    notifyListeners();

    try {
      await _inferenceService.unloadModel();
      if (_activeModel != null) {
        final index = _models.indexWhere((m) => m.id == _activeModel!.id);
        if (index != -1) {
          _models[index] = _models[index].copyWith(loadStatus: ModelLoadStatus.unloaded);
        }
        _activeModel = null;
      }
    } finally {
      _isLoading = false;
      _loadingMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _inferenceService.dispose();
    super.dispose();
  }
}
