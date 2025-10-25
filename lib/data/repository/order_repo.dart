import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_driver/data/models/order_item_details.dart';

import '../../helper/firebase_error_handler.dart';
import '../models/order_model.dart';

class DriverOrderRepository {

  final _instance=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;

  Future<List<OrderModel>> fetchOrders(String status,String? riderId) async {
    //if status is assigned fetch assigned orders else fetch unassigned orders
    // if rider id is null fetch unassigned orders else fetch assigned orders
    final querySnapshot = await _firestore
        .collection('order')
        .where('rider_id', isEqualTo: riderId).where('status',isEqualTo: status)
        .get();

    final orders = querySnapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();

    final futures = orders.map((order) async {
      final detailsSnapshot = await _firestore
          .collection('order_details')
          .where('order_id', isEqualTo: order.orderId)
          .get();

      final details = detailsSnapshot.docs
          .map((d) => OrderDetailModel.fromJson(d.data()))
          .toList();

      return order.copyWith(orderDetails: details);
    });

    // Step 3: Wait for all details to load
    final ordersWithDetails = await Future.wait(futures);

    return ordersWithDetails;
  }


  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('order').doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'updateOrderStatus');
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    String currentRiderId=_instance.currentUser!.uid;
    try {
      await _firestore.collection('order').doc(orderId).update({
        'rider_id': currentRiderId,
        'status': 'assigned',

      });
      return true;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'acceptOrder');
    }
    catch (e) {
      print('Error accepting order: $e');
      return false;
    }
  }



}