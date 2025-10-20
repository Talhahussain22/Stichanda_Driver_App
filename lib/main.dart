import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stichanda_driver/theme/light_theme.dart';
import 'package:stichanda_driver/view/screen/auth/login/login_screen.dart';
import 'package:stichanda_driver/view/screen/dashboard/dashboard_screen.dart';
import 'package:stichanda_driver/view/screen/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      home: LoginScreen(),
    );
  }
}

