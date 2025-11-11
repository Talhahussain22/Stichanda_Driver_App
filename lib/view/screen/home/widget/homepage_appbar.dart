import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../controller/authCubit.dart';
import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';

class HomepageAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size(1170, 55);

  const HomepageAppBar({super.key});

  @override
  State<HomepageAppBar> createState() => _HomepageAppBarState();
}

class _HomepageAppBarState extends State<HomepageAppBar> {
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
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isActive = (state.profile?.availabilityStatus ?? 0) == 1;
            return FlutterSwitch(
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
                if (state.isLoading) return;
                final authCubit = context.read<AuthCubit>();
                final newStatus = value ? 1 : 0;
                final ok = await authCubit.updateActiveStatus(newStatus);
                if (!context.mounted) return;
                if (ok) {
                  if (newStatus == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You're now ONLINE — tracking started ✅")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You're now OFFLINE — tracking stopped 🚫")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not update availability. Please try again.")),
                  );
                }
              },
            );
          },
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
      ],
    );
  }
}
