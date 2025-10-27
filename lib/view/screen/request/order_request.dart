import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/dashboard_index_cubit.dart';
import 'package:stichanda_driver/view/screen/request/widget/order_request_widget.dart';

import '../../../controller/OrderCubit.dart';

class OrderRequestScreen extends StatefulWidget {
  const OrderRequestScreen({super.key});

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Subscribe after first frame to avoid doing ancestor lookups during initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the widget is still mounted when subscribing
      if (!mounted) return;
      context.read<OrderCubit>().subscribeToUnassignedOrders();
    });
  }

  @override
  void dispose() {
    // If your OrderCubit has an unsubscribe method, call it here.
    // Example:
    // try {
    //   context.read<OrderCubit>().unsubscribeFromUnassignedOrders();
    // } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (ctx, state) {
        // Use the listener's context parameter (ctx), not this.context
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          if (!mounted) return;
          _scaffoldKey.currentState?.showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (ctx, state) {
        if (state.isLoading && state.orders.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.orders.isEmpty) {
          return const Scaffold(body: Center(child: Text("No order requests available")));
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Order Requests')),
          body: ListView.builder(
            itemCount: state.orders.length,
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (itemCtx, index) {
              final order = state.orders[index];

              // IMPORTANT: Capture any needed cubits / context *before* awaiting
              return OrderRequestWidget(
                order: order,
                onAccept: () async {
                  // capture contexts and cubits early (while widget is active)
                  final localCtx = itemCtx; // context for UI operations
                  final orderCubit = localCtx.read<OrderCubit>();
                  final dashboardCubit = localCtx.read<DashboardIndexCubit>();

                  // Check currentOrder before calling async operations
                  if (state.currentOrder != null) {
                    if (!mounted) return;
                    _scaffoldKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You already have an active order. Please complete it before accepting a new one.',
                        ),
                      ),
                    );
                    return;
                  }

                  // call async accept — cubit reference was captured above
                  final success = await orderCubit.acceptOrder(order.orderId);

                  // If the widget was removed while awaiting, bail out
                  if (!mounted) return;

                  if (success) {
                    // notify user, switch dashboard index and pop
                    _scaffoldKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Order accepted successfully.')),
                    );

                    // change the dashboard tab
                    dashboardCubit.setIndex(0);

                    // pop this screen (widget still mounted)
                    if (mounted) Navigator.of(localCtx).pop();
                  } else {
                    _scaffoldKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Order was already accepted by someone else.')),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
