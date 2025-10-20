// home_screen_ui.dart

import 'package:flutter/material.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/view/base/order_widget.dart';

import 'package:stichanda_driver/view/screen/home/widget/count_card.dart';
import 'package:stichanda_driver/view/screen/home/widget/homepage_appbar.dart';
import 'package:stichanda_driver/view/screen/home/widget/online_switch.dart';

import '../../../utils/dimension.dart';
import '../../../utils/style.dart';
import '../../base/order_shimmer.dart';
import '../../base/title_widget.dart';
import '../order/running_order.dart';

class HomeScreenUI extends StatelessWidget {
  // Data for the screen
  final bool isLoading;
  final List<Widget> activeOrderWidgets;

  final String? todaysOrderCount;
  final String? thisWeekOrderCount;
  final String? totalOrderCount;

  final List<OrderModel> orders = [OrderModel(
      orderId: 101,
      customerId: 125,
      totalPrice: 500,
      status: "Pending",
      paymentMethod: "cash_on_delivery",
      paymentStatus: "unpaid",
      pickupLocation: "Bhatiabad Gulistan-e-johar Karachi Block 8 ",
      dropoffLocation: "NED University of Engineering and Technology",
      pickuplongitude: "67.150215",
      pickuplatitude: " 24.914878",
      dropofflongitude: "67.1153",
      dropofflatitude: "24.9300",
      createdAt: "2025-10-16 14:30:45",
      updatedAt: "2025-10-16 14:30:45",
    ),
    // Add more orders as needed
     OrderModel(
      orderId: 102,
      customerId: 126,
      totalPrice: 750,
      status: "In Transit",
      paymentMethod: "credit_card",
      paymentStatus: "paid",
      pickupLocation: "Clifton, Karachi",
      dropoffLocation: "University of Karachi",
      pickuplongitude: "67.0011",
      pickuplatitude: "24.8090",
      dropofflongitude: "67.0099",
      dropofflatitude: "24.8607",
      createdAt: "2025-10-16 14:30:45",
      updatedAt: "2025-10-16 14:30:45",
    ),
    // Add more orders as needed
     OrderModel(
      orderId: 103,
      customerId: 127,
      totalPrice: 300,
      status: "Delivered",
      paymentMethod: "paypal",
      paymentStatus: "paid",
      pickupLocation: "Gulshan-e-Iqbal, Karachi",
      dropoffLocation: "Jinnah Hospital, Karachi",
      pickuplongitude: "67.1234",
      pickuplatitude: "24.9123",
      dropofflongitude: "67.1456",
      dropofflatitude: "24.9256",
      createdAt: "2025-10-16 14:30:45",
      updatedAt: "2025-10-16 14:30:45",
    ),
  ];

  // Callbacks for actions
  // final Future<void>? Function() onRefresh;

  final ValueChanged<bool>? onToggleOnlineStatus;
  final VoidCallback? onNotificationTap;
  final bool isOnline;
  final bool hasNotification;

   HomeScreenUI({
    Key? key,
    required this.isLoading,
    required this.activeOrderWidgets,
    required this.todaysOrderCount,
    required this.thisWeekOrderCount,
    required this.totalOrderCount,
    // required this.onRefresh,
    required this.onToggleOnlineStatus,
    required this.onNotificationTap,
    required this.isOnline,
    required this.hasNotification,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final bool hasActiveOrder = true;
    final bool hasMore= orders.length > 1;

    return Scaffold(
      appBar: HomepageAppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Orders Section
            if (isLoading || hasActiveOrder)
              Text('Active Order', style: robotoMedium),

            if (isLoading || hasActiveOrder)
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            if (isLoading)
              const OrderShimmer(isEnabled: true)
            else if (hasActiveOrder)
              OrderWidget(order: orders[0],isRunningOrder: true,),

            if (hasMore && !isLoading)
              TitleWidget(
                title: '',
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>RunningOrderScreen(currentorders: orders)));},
                orderCount: orders.length - 1,
              ),

            if (isLoading || hasActiveOrder)
              const SizedBox(height: Dimensions.paddingSizeLarge),

            // Orders Count Section
            const TitleWidget(title: 'Orders'),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Row(
              children: [
                Expanded(
                  child: CountCard(
                    title: 'Today\'s Orders',
                    backgroundColor: Theme.of(context).primaryColor,
                    height: 180,
                    value: todaysOrderCount,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: CountCard(
                    title: 'This Week\'s Orders',
                    backgroundColor:
                        Theme.of(context).primaryColor, // Example color
                    height: 180,
                    value: thisWeekOrderCount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CountCard(
              title: 'Total Orders',
              backgroundColor: Theme.of(context).primaryColor, // Example color
              height: 140,
              value: totalOrderCount,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Cash In Hand Section
          ],
        ),
      ),
    );
  }
}
