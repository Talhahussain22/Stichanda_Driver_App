import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/order_model.dart';


class DriverContactInfo extends StatelessWidget {
  final OrderModel order;

  const DriverContactInfo({super.key, required this.order});

  void _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildContactCard(
      String title, String name, String phone, String address) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(name),
            Text(address, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _callNumber(phone),
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildContactCard('Pickup (Tailor)', "order.tailorName",
            "order.tailorPhone", "order.tailorAddress"),
        _buildContactCard('Drop-off (Customer)', "order.customerName",
            "order.customerPhone", "order.customerAddress"),
      ],
    );
  }
}
