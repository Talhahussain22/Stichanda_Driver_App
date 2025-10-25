import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:stichanda_driver/services/location_service.dart';
import '../../../../controller/authCubit.dart';
import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomepageAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size(1170, 55);

  const HomepageAppBar({super.key});

  @override
  State<HomepageAppBar> createState() => _HomepageAppBarState();
}

class _HomepageAppBarState extends State<HomepageAppBar> {
  bool isActive = false;
  StreamSubscription<LocationServiceStatus>? _statusSub;
  final locationService = LocationService();

  @override
  void initState() {
    super.initState();

    // Listen to location service status changes
    _statusSub = locationService.statusStream.listen((status) {
      setState(() {
        isActive = status == LocationServiceStatus.active;
      });
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      leadingWidth: 100,
      centerTitle: true,
      titleSpacing: 0,
      elevation: 0,
      title: Text(
        'Stitchanada',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: Dimensions.fontSizeDefault,
        ),
      ),
      actions: [
        FlutterSwitch(
          width: 75,
          height: 30,
          valueFontSize: Dimensions.fontSizeExtraSmall,
          showOnOff: true,
          activeText: 'online',
          inactiveText: 'offline',
          activeColor: Colors.green,
          inactiveColor: Colors.grey,
          value: isActive,
          onToggle: (bool value) async {
            if (value) {
              await _handleGoingOnline();
            } else {
              await _handleGoingOffline();
            }
          },
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
      ],
    );
  }

  /// When driver goes online: start location tracking
  Future<void> _handleGoingOnline() async {
    final authCubit = context.read<AuthCubit>();

    // Start location tracking service
    final started = await locationService.start();

    if (started) {
      authCubit.updateActiveStatus(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You're now ONLINE — tracking started ✅")),
      );

      // Optionally listen to location changes
      locationService.locationStream.listen((position) {
        print(
            "📍 Updated Driver Location: ${position.latitude}, ${position.longitude}");
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("⚠️ Location permission denied. Please enable it.")),
      );
    }
  }

  /// When driver goes offline: stop location tracking
  Future<void> _handleGoingOffline() async {
    final authCubit = context.read<AuthCubit>();

    await locationService.stop();
    authCubit.updateActiveStatus(0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You're now OFFLINE — tracking stopped 🚫")),
    );
  }
}
