enum ModelDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
}

enum ModelLoadStatus {
  unloaded,
  loading,
  loaded,
  error,
}

class LocalModel {
  final String id;
  final String name;
  final String family;
  final String parameterSize;
  final String quantization;
  final double diskSizeGb;
  final double estimatedRamGb;
  final String description;
  final String filename;
  final ModelDownloadStatus downloadStatus;
  final ModelLoadStatus loadStatus;
  final double downloadProgress; // 0.0 to 1.0

  const LocalModel({
    required this.id,
    required this.name,
    required this.family,
    required this.parameterSize,
    required this.quantization,
    required this.diskSizeGb,
    required this.estimatedRamGb,
    required this.description,
    required this.filename,
    this.downloadStatus = ModelDownloadStatus.notDownloaded,
    this.loadStatus = ModelLoadStatus.unloaded,
    this.downloadProgress = 0.0,
  });

  LocalModel copyWith({
    String? id,
    String? name,
    String? family,
    String? parameterSize,
    String? quantization,
    double? diskSizeGb,
    double? estimatedRamGb,
    String? description,
    String? filename,
    ModelDownloadStatus? downloadStatus,
    ModelLoadStatus? loadStatus,
    double? downloadProgress,
  }) {
    return LocalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      family: family ?? this.family,
      parameterSize: parameterSize ?? this.parameterSize,
      quantization: quantization ?? this.quantization,
      diskSizeGb: diskSizeGb ?? this.diskSizeGb,
      estimatedRamGb: estimatedRamGb ?? this.estimatedRamGb,
      description: description ?? this.description,
      filename: filename ?? this.filename,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      loadStatus: loadStatus ?? this.loadStatus,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}
