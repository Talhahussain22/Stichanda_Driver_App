import 'package:flutter/material.dart';
import 'package:stichanda_driver/services/location_service.dart';
import 'package:stichanda_driver/view/screen/order/order_screen.dart';
import 'package:stichanda_driver/view/screen/profile/profile_screen.dart';
import 'package:stichanda_driver/view/screen/request/order_request.dart';

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
    HomeScreenUI(isLoading: false, activeOrderWidgets: [SizedBox()], todaysOrderCount: '2', thisWeekOrderCount: '5', totalOrderCount: '10',  onToggleOnlineStatus: null, onNotificationTap: null, isOnline: true, hasNotification: true),
    OrderRequestScreen(),
    const OrderScreen(),
    const ProfileScreen()
  ];
  int _selectedIndex=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(onTap: (int index){setState(() {
        _selectedIndex=index;
      });},
      type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,items: [
        BottomNavigationBarItem(icon: Icon(Icons.home,color: _selectedIndex==0?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt,color: _selectedIndex==1?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag,color: _selectedIndex==2?Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Order History'),
        BottomNavigationBarItem(icon: Icon(Icons.person,color: _selectedIndex==3? Theme.of(context).primaryColor:Theme.of(context).hintColor,),label: 'Profile'),
      ],),
      body: _screens[_selectedIndex],
    );
  }
}
