import 'package:flutter/material.dart';
import '../../../../data/models/order_model.dart';


class DriverOrderStatusButton extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onUpdateStatus;

  const DriverOrderStatusButton({
    super.key,
    required this.order,
    required this.onUpdateStatus,
  });

  String? getNextStatus(String current) {
    switch (current.toLowerCase()) {
      case 'pending':
        return 'accepted';
      case 'accepted':
        return 'pickedup';
      case 'pickedup':
        return 'delivered';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextStatus = getNextStatus(order.status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: onUpdateStatus,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Text('Mark as $nextStatus'.toUpperCase()),
      ),
    );
  }
}
