import 'package:flutter/material.dart';
import 'package:idam/screens/splash_screen.dart';
import 'services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.initialize();
  runApp(const IdamApp());
}

class IdamApp extends StatefulWidget {
  const IdamApp({super.key});

  @override
  State<IdamApp> createState() => _IdamAppState();
}

class _IdamAppState extends State<IdamApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AudioManager.instance.resumeMusic();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        AudioManager.instance.pauseMusic();
        break;

      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF000000),
        scaffoldBackgroundColor: const Color(0xFF000000),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}