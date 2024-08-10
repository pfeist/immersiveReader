import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:immersive_reader/screens/home_screen.dart';
import 'package:immersive_reader/providers/theme_notifier.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Immersive Reader',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
                accentColor: Colors.amber,  // accentColor is used within colorScheme
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontSize: 16.0),
                displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              ),
              buttonTheme: const ButtonThemeData(
                buttonColor: Colors.blue,
                textTheme: ButtonTextTheme.primary,
              ),
              appBarTheme: const AppBarTheme(
                color: Colors.blue,  // Set a universal color for app bars
              ),
            ),
            darkTheme: ThemeData.dark(),
            themeMode: theme.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
