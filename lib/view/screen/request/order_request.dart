import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/view/screen/request/widget/order_request_widget.dart';

import '../../../controller/OrderCubit.dart';
import '../../../data/models/order_model.dart';

class OrderRequestScreen extends StatefulWidget {
  const OrderRequestScreen({super.key});

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {

  @override
  void initState() {
    super.initState();
    _loadOrders();

  }

  void _loadOrders() {
      context.read<OrderCubit>().fetchUnAssignedOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context,state) {
        if(state.orders==null){
          return const Center(child: CircularProgressIndicator());
        }
        if (state.orders.isEmpty) {
          return const Center(child: Text("No order requests available"));
        }
        return Scaffold(
          appBar: AppBar(title: Text('Order Requests')),
          body:RefreshIndicator(
                onRefresh: () async => _loadOrders(),
                child: ListView.builder(
                  itemCount: state.orders.length,
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return OrderRequestWidget(
                      order: order,
                      onAccept: () => {
                        if(state.currentOrder!=null){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You already have an active order. Please complete it before accepting a new one.')),
                          )
                        }else{
                          context.read<OrderCubit>().acceptOrder(order.orderId).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order accepted successfully.')),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to accept order: $error')),
                            );
                          })
                        }
                      //   if one driver accept order assign driver id in backend and  change order status to accepted in backend so it don't show to others
                      },
                      
                    );
                  },
                ),));
      }
    );
    }
  }



// final List<OrderModel> orders = [
//   OrderModel(
//     orderId: 101,
//     customerId: 201,
//     tailorId: 501,
//     riderId: 301,
//     totalPrice: 2500.0,
//     status: "pending",
//     paymentMethod: "Cash on Delivery",
//     paymentStatus: "unpaid",
//     pickupLocation: "NED University, University Road, Karachi",
//     pickuplatitude: "24.9300",
//     pickuplongitude: "67.1153",
//     dropoffLocation: "gulistan-e-johar johar chowrangi, karachi, sindh, pakistan",
//     dropofflatitude: "24.9084",
//     dropofflongitude: "67.1186",
//     deliveryDate: "2025-10-16",
//     createdAt: "2025-10-15 10:00:00",
//     updatedAt: "2025-10-15 10:00:00",
//   ),
//
//   OrderModel(
//     orderId: 102,
//     customerId: 202,
//     tailorId: 502,
//     riderId: 302,
//     totalPrice: 1800.0,
//     status: "accepted",
//     paymentMethod: "Online",
//     paymentStatus: "paid",
//     pickupLocation: "Saddar, Karachi",
//     pickuplatitude: "24.8535",
//     pickuplongitude: "67.0168",
//     dropoffLocation: "Clifton Block 5, Karachi",
//     dropofflatitude: "24.8266",
//     dropofflongitude: "67.0356",
//     deliveryDate: "2025-10-17",
//     createdAt: "2025-10-15 09:30:00",
//     updatedAt: "2025-10-15 11:00:00",
//   ),
//
//   OrderModel(
//     orderId: 103,
//     customerId: 203,
//     tailorId: 503,
//     riderId: 303,
//     totalPrice: 3200.0,
//     status: "pending",
//     paymentMethod: "Card Payment",
//     paymentStatus: "paid",
//     pickupLocation: "Gulshan-e-Iqbal Block 13-D, Karachi",
//     pickuplatitude: "24.9261",
//     pickuplongitude: "67.0926",
//     dropoffLocation: "Gulistan-e-Johar Block 7, Karachi",
//     dropofflatitude: "24.9171",
//     dropofflongitude: "67.1242",
//     deliveryDate: "2025-10-16",
//     createdAt: "2025-10-15 12:15:00",
//     updatedAt: "2025-10-15 12:15:00",
//   ),
//
//   OrderModel(
//     orderId: 104,
//     customerId: 204,
//     tailorId: 504,
//     riderId: 304,
//     totalPrice: 2900.0,
//     status: "pending",
//     paymentMethod: "Cash",
//     paymentStatus: "paid",
//     pickupLocation: "Korangi Industrial Area, Karachi",
//     pickuplatitude: "24.8324",
//     pickuplongitude: "67.1326",
//     dropoffLocation: "PECHS Block 6, Karachi",
//     dropofflatitude: "24.8683",
//     dropofflongitude: "67.0605",
//     deliveryDate: "2025-10-17",
//     createdAt: "2025-10-15 08:45:00",
//     updatedAt: "2025-10-15 09:00:00",
//   ),
//
//   OrderModel(
//     orderId: 105,
//     customerId: 205,
//     tailorId: 505,
//     riderId: 305,
//     totalPrice: 1500.0,
//     status: "pending",
//     paymentMethod: "JazzCash",
//     paymentStatus: "paid",
//     pickupLocation: "Nazimabad Block 3, Karachi",
//     pickuplatitude: "24.9170",
//     pickuplongitude: "67.0345",
//     dropoffLocation: "North Karachi Sector 11-B, Karachi",
//     dropofflatitude: "24.9703",
//     dropofflongitude: "67.0645",
//     deliveryDate: "2025-10-16",
//     createdAt: "2025-10-15 14:20:00",
//     updatedAt: "2025-10-15 14:20:00",
//   ),
// ];