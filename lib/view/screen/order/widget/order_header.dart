import 'package:flutter/material.dart';
import '../../../../data/models/order_model.dart';


class DriverOrderHeader extends StatelessWidget {
  final OrderModel order;

  const DriverOrderHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Order #${order.orderId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Payment: ${order.paymentMethod}'),
        trailing: Chip(
          label: Text(order.status.toUpperCase()),
          backgroundColor: _statusColor(order.status).withOpacity(0.1),
          labelStyle: TextStyle(color: _statusColor(order.status)),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'pickedup':
        return Colors.blue;
      case 'delivered':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
