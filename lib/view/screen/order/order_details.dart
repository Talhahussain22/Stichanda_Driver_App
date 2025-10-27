import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stichanda_driver/controller/OrderCubit.dart';
import 'package:stichanda_driver/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_driver/modules/chat/screens/chat_screen.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/data/repository/order_repo.dart';

class DriverOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const DriverOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<DriverOrderDetailsScreen> createState() =>
      _DriverOrderDetailsScreenState();
}

class _DriverOrderDetailsScreenState extends State<DriverOrderDetailsScreen> {

  @override
  void initState() {
    context.read<OrderCubit>().loadOrderById(widget.orderId);
    super.initState();
  }
  void _onAdvanceStatus(OrderModel order) async {
    final orderCubit = context.read<OrderCubit>();
    final next = _nextStatus(order.status);
    if (next == null) return;
    if (next == 'completed') {
      await orderCubit!.completeSelectedOrder();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order completed')));
      Navigator.of(context).pop(true);
    } else {
      orderCubit!.updateOrderStatus(order.orderId, next);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order marked as $next')));
    }
  }

  String? _nextStatus(String s) {
    switch (s.toLowerCase()) {
      case 'assigned':
        return 'picked_up';
      case 'picked_up':
        return 'completed';
      default:
        return '';
    }
  }

  Future<void> _openDirections(double lat, double lng) async {

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&mode=d';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch: $url')));
    }
  }

  Future<void> _call(String number) async {
    if (number.isEmpty) return;

    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {

      await launchUrl(uri, mode: LaunchMode.externalApplication,);
    }
  }

  Future<void> _startChat(String otherUserId) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || otherUserId.isEmpty) return;
    final cubit = context.read<ChatCubit>();
    final conv = await cubit.startConversation(me, otherUserId);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
    );
  }

  Widget _sectionCard({required Widget child, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            child,
            if (trailing != null) Positioned(top: 0, right: 0, child: trailing),
          ],
        ),
      ),
    );
  }

  Widget _basicInfo(OrderModel o) {

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #${o.orderId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments, size: 18),
              const SizedBox(width: 6),
              Text('Payment: ${o.paymentMethod} • ${o.paymentStatus}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 18),
              const SizedBox(width: 6),
              Text('Total: ${o.totalPrice.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );

  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 16, child: Icon(icon, size: 18)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value.isEmpty ? '-' : value),
      onTap: onTap,
    );
  }

  Widget _customerCard(OrderModel o,bool isTailor) {


    //in fututre replace cusotmer and tailor with sender and reciver and in address
    // also check order_status to show pickup or dropoff location , selecting sender and reicver etc
    final addr =isTailor?o.dropoffLocation:o.pickupLocation;
    final lat = double.tryParse(addr?.latitude ?? '');
    final lng = double.tryParse(addr?.longitude ?? '');

    return _sectionCard(
      trailing:
          (lat != null && lng != null)
              ? IconButton(
                tooltip: 'Directions',
                icon: Icon(Icons.directions,color: Theme.of(context).primaryColor,),
                onPressed: () => _openDirections(lat, lng),
              )
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            isTailor?'Tailor':'Customer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _contactRow(
            icon: Icons.person,
            label: 'Name',
            value: isTailor? o.tailor?.name ?? '-':o.customer?.name ?? '-',
          ),
          _contactRow(
            icon: Icons.location_on,
            label: 'Address',
            value: addr?.location ?? '-',
          ),
          _contactRow(
            icon: Icons.phone,
            label: 'Phone',
            value: isTailor? o.tailor?.phone ?? '-':o.customer?.phone ?? '',
            onTap: () => _call(isTailor? o.tailor?.phone ?? '-':o.customer?.phone ?? ''),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  onPressed:
                      (isTailor? o.tailor?.phone ?? '-':o.customer?.phone ?? '').isEmpty
                          ? null
                          : () => _call(isTailor? o.tailor?.phone ?? '-':o.customer?.phone ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  onPressed: () => _startChat(o.customerId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final isLoading = state.isLoading && (state.selectedOrder == null);
        final selected = state.selectedOrder;
        final canUpdate =
            selected != null && _nextStatus(selected.status) != null;

        return Scaffold(
          appBar: AppBar(title: const Text('Order Details')),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selected == null
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 240),
                      Center(child: Text('No order found')),
                    ],
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              _basicInfo(selected),
                              _customerCard(selected,false),
                              _customerCard(selected,true),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  canUpdate
                                      ? () => _onAdvanceStatus(selected)
                                      : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                _nextStatus(selected.status) == 'completed'
                                    ? 'Complete Order'
                                    : 'Mark as ${_nextStatus(selected.status)!.replaceAll('_', ' ').toUpperCase()}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
