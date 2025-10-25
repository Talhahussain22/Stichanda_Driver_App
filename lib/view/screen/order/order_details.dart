// import 'package:flutter/material.dart';
// import 'package:stichanda_driver/view/screen/order/widget/contact_info.dart';
// import 'package:stichanda_driver/view/screen/order/widget/order_header.dart';
// import 'package:stichanda_driver/view/screen/order/widget/order_status_button.dart';
// import '../../../data/models/order_model.dart';
// import '../../../data/repository/order_repo.dart';
//
//
// class DriverOrderDetailsScreen extends StatefulWidget {
//   final int orderId;
//   const DriverOrderDetailsScreen({super.key, required this.orderId});
//
//   @override
//   State<DriverOrderDetailsScreen> createState() =>
//       _DriverOrderDetailsScreenState();
// }
//
// class _DriverOrderDetailsScreenState extends State<DriverOrderDetailsScreen> {
//   final repo = DriverOrderRepository();
//   OrderModel? order;
//   bool loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOrder();
//   }
//
//   Future<void> _loadOrder() async {
//     final data = await repo.getOrderById(widget.orderId);
//     setState(() {
//       order = data;
//       loading = false;
//     });
//   }
//
//   Future<void> _updateStatus() async {
//     if (order == null) return;
//     final next = _nextStatus(order!.status);
//     if (next == null) return;
//     final ok = await repo.updateOrderStatus(order!.orderId, next);
//     if (ok) {
//       setState(() => order!.status = next);
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Order marked as $next')));
//     }
//   }
//
//   String? _nextStatus(String s) {
//     switch (s.toLowerCase()) {
//       case 'pending':
//         return 'accepted';
//       case 'accepted':
//         return 'pickedup';
//       case 'pickedup':
//         return 'delivered';
//       default:
//         return null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Order Details')),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : order == null
//           ? const Center(child: Text('No order found'))
//           : Column(children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 DriverOrderHeader(order: order!),
//                 DriverContactInfo(order: order!),
//               ],
//             ),
//           ),
//         ),
//         DriverOrderStatusButton(
//           order: order!,
//           onUpdateStatus: _updateStatus,
//         ),
//       ]),
//     );
//   }
// }
