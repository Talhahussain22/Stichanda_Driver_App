import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/order_model.dart';
import '../screen/order/order_details.dart';

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
    final bool showDropoff = (order.status == 2 || order.status == 7);
    final displayLocation = showDropoff ? order.currentDropoffLocation : order.currentPickupLocation;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Row: Order ID ---
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
              // Status badge

            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              order.statusLabel,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // --- Address Information ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                showDropoff ? Icons.location_on : Icons.location_on_outlined,
                size: 20,
                color: showDropoff ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showDropoff ? 'Deliver to:' : 'Pick up from:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayLocation.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DriverOrderDetailsScreen(orderId: order.orderId)));
                      },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 8),

            ],
          ),
        ],
      ),
    );
  }
}
