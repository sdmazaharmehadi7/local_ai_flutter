import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'state/app_scope.dart';
import 'state/chat_state.dart';
import 'state/model_state.dart';
import 'state/settings_state.dart';
import 'ui/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SovereignApp());
}

class SovereignApp extends StatefulWidget {
  const SovereignApp({super.key});

  @override
  State<SovereignApp> createState() => _SovereignAppState();
}

class _SovereignAppState extends State<SovereignApp>
    with WidgetsBindingObserver {
  late final SettingsState _settingsState;
  late final ModelState _modelState;
  late final ChatState _chatState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settingsState = SettingsState();
    _modelState = ModelState();
    _chatState = ChatState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Safe lifecycle handling: stop in-flight native generation when app goes to background
      if (_chatState.isGenerating) {
        _chatState.stopGeneration(
          inferenceService: _modelState.inferenceService,
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatState.dispose();
    _modelState.dispose();
    _settingsState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_settingsState, _modelState, _chatState]),
      builder: (context, _) {
        return AppScope(
          settingsState: _settingsState,
          modelState: _modelState,
          chatState: _chatState,
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settingsState.themeMode,
            home: const AppShell(),
          ),
        );
      },
    );
  }
}
