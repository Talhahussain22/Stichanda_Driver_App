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
import 'package:stichanda_driver/view/screen/splash/splash_screen.dart';

import 'firebase_options.dart';

class _LifecycleHandler extends WidgetsBindingObserver {
  final AuthCubit authCubit;
  _LifecycleHandler(this.authCubit);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app goes to background or detached, set availability offline
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      authCubit.updateActiveStatus(0);
    }
  }
}

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _LifecycleHandler? _lifecycleHandler;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
            authRepo: AuthRepo(),
            locationService: LocationService(),
          ),
        ),
        BlocProvider(
            create: (context) =>
                OrderCubit(orderRepository: DriverOrderRepository()))
      ],
      child: Builder(
        builder: (context) {
          // Attach lifecycle observer once AuthCubit is available
          _lifecycleHandler ??= _LifecycleHandler(context.read<AuthCubit>());
          WidgetsBinding.instance.addObserver(_lifecycleHandler!);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (_lifecycleHandler != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleHandler!);
    }
    super.dispose();
  }
}
