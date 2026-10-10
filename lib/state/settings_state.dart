import 'package:flutter/material.dart';
import '../models/generation_settings.dart';

class SettingsState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  GenerationSettings _generationSettings = const GenerationSettings();

  ThemeMode get themeMode => _themeMode;
  GenerationSettings get generationSettings => _generationSettings;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void updateGenerationSettings(GenerationSettings newSettings) {
    _generationSettings = newSettings;
    notifyListeners();
  }

  void resetToDefaults() {
    _generationSettings = const GenerationSettings();
    notifyListeners();
  }
}
