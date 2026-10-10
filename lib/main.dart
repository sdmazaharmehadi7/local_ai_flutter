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

class _SovereignAppState extends State<SovereignApp> {
  late final SettingsState _settingsState;
  late final ModelState _modelState;
  late final ChatState _chatState;

  @override
  void initState() {
    super.initState();
    _settingsState = SettingsState();
    _modelState = ModelState();
    _chatState = ChatState();
  }

  @override
  void dispose() {
    _settingsState.dispose();
    _modelState.dispose();
    _chatState.dispose();
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
