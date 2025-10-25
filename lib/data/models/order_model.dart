import 'order_item_details.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String? tailorId;
  final String? riderId;
  final double totalPrice;
  String status;
  final String paymentMethod;
  final String paymentStatus;
  final Address pickupLocation;
  final Address dropoffLocation;
  final String? deliveryDate;
  final String createdAt;
  final String updatedAt;

  final List<OrderDetailModel>? orderDetails;

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
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    this.orderDetails,
  });


  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    Map<String, dynamic> pickup = json['pickup_location'] ?? {};
    Map<String, dynamic> dropoff = json['dropoff_location'] ?? {};

    return OrderModel(
      orderId: json['order_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      tailorId: json['tailor_id']?.toString(),
      riderId: json['rider_id']?.toString(),
      totalPrice: _parseDouble(json['total_price']),
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      pickupLocation: Address.fromJson(pickup),
      dropoffLocation: Address.fromJson(dropoff),
      deliveryDate: json['delivery_date']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'tailor_id': tailorId,
      'rider_id': riderId,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'pickup_location': pickupLocation.toJson(),
      'dropoff_location': dropoffLocation.toJson(),
      'delivery_date': deliveryDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }


  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? tailorId,
    String? riderId,
    double? totalPrice,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    Address? pickupLocation,
    Address? dropoffLocation,
    String? deliveryDate,
    String? createdAt,
    String? updatedAt,
    List<OrderDetailModel>? orderDetails,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      tailorId: tailorId ?? this.tailorId,
      riderId: riderId ?? this.riderId,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, totalPrice: $totalPrice, status: $status, items: ${orderDetails?.length ?? 0})';
  }
}


class Address {
  final String location;
  final String latitude;
  final String longitude;

  Address({
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      location: json['full_address'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_address': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'Address($location, $latitude, $longitude)';
}
