import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/view/screen/auth/login/login_screen.dart';
import 'package:stichanda_driver/view/screen/auth/pending_status_screen.dart';
import 'package:stichanda_driver/view/screen/dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  void _navigateOnce(Widget page) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => page),
            (route) => false,
      );
    }); // Optional delay for splash effect

  }

  @override
  void initState() {
    super.initState();
    // Handle race condition: if Cubit emitted before listener attached, decide based on current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;

      if (state.isLoading) return; // let listener handle when it flips to false

      if (state.isAuthenticated && state.profile != null) {
        final status = state.profile!.verificationStatus;

        if (status == 0) {
          _navigateOnce(const PendingStatusScreen());
        } else if (status == 1) {
          _navigateOnce(DashboardScreen());
        } else if (status == 2) {
          context.read<AuthCubit>().logout();
          _navigateOnce(const LoginScreen(initialSnack: 'Your account has been rejected.'));
        } else {
          _navigateOnce(const LoginScreen());
        }
      } else {
        _navigateOnce(const LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, next) => prev.isLoading != next.isLoading || prev.isAuthenticated != next.isAuthenticated || prev.profile != next.profile,
      listener: (context, state) {
        if (state.isLoading) return;

        if (state.isAuthenticated && state.profile != null) {
          final status = state.profile!.verificationStatus;
          if (status == 0) {
            _navigateOnce(const PendingStatusScreen());
          } else if (status == 1) {
            _navigateOnce(DashboardScreen());
          } else if (status == 2) {
            context.read<AuthCubit>().logout();
            _navigateOnce(const LoginScreen(initialSnack: 'Your account has been rejected.'));
          } else {
            _navigateOnce(const LoginScreen());
          }
        } else {

          _navigateOnce(const LoginScreen());
        }
      },
      child:  Scaffold(
        body: Center(
          child:Image.asset('assets/images/splash_logo.png', width: double.infinity,height: double.infinity,),

        ),
      ),
    );
  }
}
