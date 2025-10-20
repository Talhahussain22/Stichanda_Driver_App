import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../data/models/order_model.dart';


// for now location services is place here and also this page is getting location of driver we will shift this to homepage after some time and locator service to repository
class OrderRequestWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onAccept;
  final VoidCallback? onIgnore;

  const OrderRequestWidget({
    super.key,
    required this.order,
    this.onAccept,
    this.onIgnore,
  });

  @override
  State<OrderRequestWidget> createState() => _OrderRequestWidgetState();
}

class _OrderRequestWidgetState extends State<OrderRequestWidget> {
  double? _driverLat;
  double? _driverLng;
  double? _distanceToPickup;
  double? _distancePickupToDropoff;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initDriverLocation();
  }

  Future<void> _initDriverLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if(!await Geolocator.isLocationServiceEnabled()) {
          return;
        }

      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final pickupLat = double.tryParse(widget.order.pickuplatitude) ?? 0.0;
      final pickupLng = double.tryParse(widget.order.pickuplongitude) ?? 0.0;
      final dropoffLat = double.tryParse(widget.order.dropofflatitude) ?? 0.0;
      final dropoffLng = double.tryParse(widget.order.dropofflongitude) ?? 0.0;

      final double driverToPickup =
      _calculateDistance(pos.latitude, pos.longitude, pickupLat, pickupLng);



      final double pickupToDropoff =
      _calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng);
      print('distance from pickup to dropoff with pickup latitude $pickupLat and pickup longitude $pickupLng and dropoff latitude $dropoffLat and dropoff longitude $dropoffLng is $pickupToDropoff km  with current driver latitude ${pos.latitude} and driver longitude ${pos.longitude}');

      setState(() {
        _driverLat = pos.latitude;
        _driverLng = pos.longitude;
        _distanceToPickup = driverToPickup;
        _distancePickupToDropoff = pickupToDropoff;
        _loadingLocation = false;
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() => _loadingLocation = false);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2)/1000;


  }


  Future<void> _openGoogleMaps(
      double destLat, double destLng, String destinationName) async {
    if (_driverLat == null || _driverLng == null) return;

    print(_driverLat);
    print(_driverLng);

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$_driverLat,$_driverLng&destination=$destLat,$destLng&travelmode=driving';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch directions to $destinationName")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return order.status.toLowerCase() != 'pending'
        ? const SizedBox() // hide non-pending orders
        : Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingLocation
        //replace this with shimmer card later or only part where distance is being calculate
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order.orderId}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    order.paymentStatus.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor:
                  order.paymentStatus.toLowerCase() == 'paid'
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Payment details
            if(order.paymentStatus=='unpaid')
            Row(
              children: [
                Icon(Icons.payment,
                    size: 18,
                    color:
                    order.paymentStatus.toLowerCase() == 'paid'
                        ? Colors.green
                        : Colors.red),
                const SizedBox(width: 6),

                Text(
                  "Amount: ${order.totalPrice.toStringAsFixed(2)} PKR",
                  style: TextStyle(
                    color: order.paymentStatus.toLowerCase() == 'paid'
                        ? Colors.green[800]
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pickup
            _buildLocationRow(
              icon: Icons.store,
              label: "Pickup Location",
              address: order.pickupLocation,
              distanceText:
              "📍 You are ${_distanceToPickup?.toStringAsFixed(2)} km away",
              onViewMap: () => _openGoogleMaps(
                  double.tryParse(order.pickuplatitude) ?? 0.0,
                  double.tryParse(order.pickuplongitude) ?? 0.0,
                  "Pickup"),
            ),
            const SizedBox(height: 8),

            // Dropoff
            _buildLocationRow(
              icon: Icons.location_pin,
              label: "Dropoff Location",
              address: order.dropoffLocation,
              distanceText:
              "🚚 Customer is ${_distancePickupToDropoff?.toStringAsFixed(2)} km from pickup",
              onViewMap: () => _openGoogleMaps(
                  double.tryParse(order.dropofflatitude) ?? 0.0,
                  double.tryParse(order.dropofflongitude) ?? 0.0,
                  "Dropoff"),
            ),
            const Divider(height: 24),




            // Buttons
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onIgnore,
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text("Ignore",
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onAccept,
                  icon: const Icon(Icons.check_circle,
                      color: Colors.white),
                  label: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String address,
    required String distanceText,
    required VoidCallback onViewMap,
  }) {
    return Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20, color: Colors.blueGrey),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(address,
                style:
                const TextStyle(color: Colors.black87, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(distanceText,
                    style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
                IconButton(
                  icon: const Icon(Icons.map,
                      color: Colors.blueAccent, size: 20),
                  tooltip: "Open in Maps",
                  onPressed: onViewMap,
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
