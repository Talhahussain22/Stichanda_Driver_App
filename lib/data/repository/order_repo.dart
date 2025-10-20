

import '../models/order_model.dart';

class DriverOrderRepository {
  Future<OrderModel> getOrderById(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return OrderModel(
      orderId: 101,
      customerId: 201,
      tailorId: 501,
      riderId: 301,
      totalPrice: 2500.0,
      status: "pending",
      paymentMethod: "Cash on Delivery",
      paymentStatus: "unpaid",
      pickupLocation: "NED University, University Road, Karachi",
      pickuplatitude: "24.9300",
      pickuplongitude: "67.1153",
      dropoffLocation: "gulistan-e-johar johar chowrangi, karachi, sindh, pakistan",
      dropofflatitude: "24.9084",
      dropofflongitude: "67.1186",
      deliveryDate: "2025-10-16",
      createdAt: "2025-10-15 10:00:00",
      updatedAt: "2025-10-15 10:00:00",
    );
  }

  Future<bool> updateOrderStatus(int id, String newStatus) async {
    // Call API here
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
