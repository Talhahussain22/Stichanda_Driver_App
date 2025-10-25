// home_screen_ui.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/view/base/order_widget.dart';

import 'package:stichanda_driver/view/screen/home/widget/count_card.dart';
import 'package:stichanda_driver/view/screen/home/widget/homepage_appbar.dart';
import 'package:stichanda_driver/view/screen/home/widget/online_switch.dart';

import '../../../controller/OrderCubit.dart';
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


    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context,state) {
        final bool hasActiveOrder = state.currentOrder != null;

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
                if (hasActiveOrder)
                  Text('Active Order', style: robotoMedium),

                if (isLoading || hasActiveOrder)
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                if (isLoading)
                  const OrderShimmer(isEnabled: true)
                else if (hasActiveOrder)
                  OrderWidget(order: state.currentOrder!,isRunningOrder: true,),



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
    );
  }
}
