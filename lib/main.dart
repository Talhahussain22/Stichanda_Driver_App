import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/OrderCubit.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/data/repository/auth_repo.dart';
import 'package:stichanda_driver/data/repository/order_repo.dart';
import 'package:stichanda_driver/services/location_service.dart';
import 'package:stichanda_driver/theme/light_theme.dart';
import 'package:stichanda_driver/view/screen/auth/login/login_screen.dart';
import 'package:stichanda_driver/view/screen/dashboard/dashboard_screen.dart';
import 'package:stichanda_driver/view/screen/home/home_screen.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        BlocProvider(create: (context)=>AuthCubit(authRepo: AuthRepo(), locationService: LocationService()),),
        BlocProvider(create: (context)=>OrderCubit(orderRepository: DriverOrderRepository()))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: lightTheme,
        home: LoginScreen(),
      ),
    );
  }
}

