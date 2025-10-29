import 'package:flutter/material.dart';
import 'controllers/settings_controller.dart';
import 'screens/menu_screen.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController(
    SettingsService(),
    BackgroundAudioService(),
  );
  await settingsController.loadSettings();

  runApp(BubblePopLabApp(settingsController: settingsController));
  final binding = WidgetsBinding.instance;
  binding.addObserver(_LifecycleHandler(settingsController));
}

class BubblePopLabApp extends StatelessWidget {
  const BubblePopLabApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Bubble Pop Lab',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
          ),
          home: MenuScreen(settingsController: settingsController),
        );
      },
    );
  }
}

class _LifecycleHandler extends WidgetsBindingObserver {
  _LifecycleHandler(this.settingsController);

  final SettingsController settingsController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      settingsController.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      settingsController.refreshMusicState();
    }
  }
}
