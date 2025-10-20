import 'package:flutter/material.dart';
import 'package:stichanda_driver/view/screen/order/order_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../data/models/order_model.dart';

/// Simple data model to represent an order.
/// You can replace or extend this with your real data class.
/// A reusable order item card with a “Details” and “Direction” button.
class OrderWidget extends StatelessWidget {
  final OrderModel order;
  final bool isRunningOrder;
  final VoidCallback? onDetailsPressed;

  const OrderWidget({
    super.key,
    required this.order,
    this.isRunningOrder = false,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCOD = order.paymentMethod == 'cash_on_delivery';
    final bool isPaid = order.paymentMethod == 'paid';
    final bool isPickedUp = order.status == 'picked_up'; // this is very useful for determining which location to show and navigate to,

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Row: Order ID + Payment Type ---
          Row(
            children: [
              Text(
                'Order ID:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '#${order.orderId}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isCOD ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isPaid
                    ? 'Paid'
                    : isCOD
                    ? 'COD'
                    : 'Digital',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- Address Information ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                 isPickedUp
                      ? order.dropoffLocation
                      : order.pickupLocation,
                      
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Action Buttons ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetailsPressed ??
                          () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DriverOrderDetailsScreen(orderId: order.orderId!)));
                      },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    
                    final lat =isPickedUp?order.dropofflatitude:order.pickuplatitude;
                    final lng =isPickedUp? order.dropofflongitude:order.pickuplongitude;
                    final url =
                        'https://www.google.com/maps/dir/?api=1&destination=${double.parse(lat)},${double.parse(lng)}&mode=d';

                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch: $url')),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Direction'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
