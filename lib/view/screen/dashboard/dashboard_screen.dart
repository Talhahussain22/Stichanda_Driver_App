import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/view/screen/order/order_screen.dart';
import 'package:stichanda_driver/view/screen/profile/profile_screen.dart';
import 'package:stichanda_driver/view/screen/request/order_request.dart';
import 'package:stichanda_driver/modules/chat/screens/conversations_screen.dart';
import 'package:stichanda_driver/controller/dashboard_index_cubit.dart';

import '../home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }
  final _screens=[
    HomeScreenUI(),
    OrderRequestScreen(),
    ConversationsScreen(),
    const OrderScreen(),
    const ProfileScreen()
  ];

  Future<void> _onNavTap(int index) async {
    if(index==1){
      // Check online availability (Firestore status)
      final availability = context.read<AuthCubit>().state.profile?.availabilityStatus ?? 0;
      final isassigned = context.read<AuthCubit>().state.profile?.isAssigned ?? 0;

      if(availability!=1 ){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=>AlertDialog(
            title: const Text('Offline'),
            content: const Text('You are offline now. You have to go online to view order requests'),
            actions: [
              TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('OK'))
            ],
          ),
        );
        return;
      }

      else if(isassigned==1){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=>AlertDialog(
            title: const Text('Busy'),
            content: const Text('You are assigned to an order. You cannot view new order requests now.'),
            actions: [
              TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('OK'))
            ],
          ),
        );
        return;
      }
      // Check device location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(!serviceEnabled){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=>AlertDialog(
            title: const Text('Offline'),
            content: const Text('You are offline now. You have to go online to view order requests'),
            actions: [
              TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('OK'))
            ],
          ),
        );
        return;
      }
      // Optionally guard permissions too
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=>AlertDialog(
            title: const Text('Offline'),
            content: const Text('You are offline now. You have to go online to view order requests'),
            actions: [
              TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('OK'))
            ],
          ),
        );
        return;
      }
    }
    context.read<DashboardIndexCubit>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardIndexCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            onTap: (i){ _onNavTap(i); },
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home,color: selectedIndex==0?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt,color: selectedIndex==1?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.chat,color: selectedIndex==2?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Chats'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag,color: selectedIndex==3?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Order History'),
              BottomNavigationBarItem(icon: Icon(Icons.person,color: selectedIndex==4? Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Profile'),
            ],
          ),
          body: _screens[selectedIndex],
        );
      },
    );
  }
}
