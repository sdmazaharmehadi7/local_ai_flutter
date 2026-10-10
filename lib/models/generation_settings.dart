class GenerationSettings {
  final double temperature;
  final double topP;
  final int contextWindow;
  final int maxTokens;
  final String systemPrompt;
  final bool useGpuAcceleration;

  const GenerationSettings({
    this.temperature = 0.7,
    this.topP = 0.9,
    this.contextWindow = 4096,
    this.maxTokens = 1024,
    this.systemPrompt =
        'You are Sovereign AI, an intelligent, private, and completely offline assistant running locally on this machine.',
    this.useGpuAcceleration = true,
  });

  GenerationSettings copyWith({
    double? temperature,
    double? topP,
    int? contextWindow,
    int? maxTokens,
    String? systemPrompt,
    bool? useGpuAcceleration,
  }) {
    return GenerationSettings(
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      contextWindow: contextWindow ?? this.contextWindow,
      maxTokens: maxTokens ?? this.maxTokens,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      useGpuAcceleration: useGpuAcceleration ?? this.useGpuAcceleration,
    );
  }
}
