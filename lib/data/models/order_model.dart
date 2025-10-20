class OrderModel {
  final int orderId;
  final int customerId;
  final int? tailorId;
  final int? riderId;
  final double totalPrice;
  String status;
  final String paymentMethod;
  final String paymentStatus;
  final String pickupLocation;
  final String dropoffLocation;
  final String pickuplongitude;
  final String pickuplatitude;
  final String dropofflongitude;
  final String dropofflatitude;
  final String? deliveryDate;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
    this.tailorId,
    this.riderId,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickuplongitude,
    required this.pickuplatitude,
    required this.dropofflongitude,
    required this.dropofflatitude,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create an instance from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] is String
          ? int.parse(json['order_id'])
          : json['order_id'],
      customerId: json['customer_id'] is String
          ? int.parse(json['customer_id'])
          : json['customer_id'],
      tailorId: json['tailor_id'] != null
          ? (json['tailor_id'] is String
          ? int.parse(json['tailor_id'])
          : json['tailor_id'])
          : null,
      riderId: json['rider_id'] != null
          ? (json['rider_id'] is String
          ? int.parse(json['rider_id'])
          : json['rider_id'])
          : null,
      totalPrice: json['total_price'] is String
          ? double.parse(json['total_price'])
          : json['total_price'].toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      pickupLocation: json['pickup_location'] ?? '',
      dropoffLocation: json['dropoff_location'] ?? '',
      pickuplongitude: json['pickuplongitude'] ?? '',
      pickuplatitude: json['pickuplatitude'] ?? '',
      dropofflongitude: json['dropofflongitude'] ?? '',
      dropofflatitude: json['dropofflatitude'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      createdAt: json['created_at']??'',
      updatedAt: json['updated_at']??'',
    );
  }



  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, customerId: $customerId, tailorId: $tailorId, riderId: $riderId, totalPrice: $totalPrice, status: $status, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus)';
  }
}
