import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/history_provider.dart';
import 'providers/model_provider.dart';
import 'screens/main_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    // To make some variables global, we use Provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ModelProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Plant Recogniser Min 2025',
            theme: themeProvider.currentTheme,
            home: const MainScreen(title: "Tensor Guessr"),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
