import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helper/firebase_error_handler.dart';
import '../models/order_model.dart';

class DriverOrderRepository {

  final _instance=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;

  Future<List<OrderModel>> fetchOrders(String status,String? riderId) async {
    final col = _firestore.collection('order');
    Query<Map<String, dynamic>> query = col.where('status', isEqualTo: status);
    if (riderId != null) {
      query = query.where('rider_id', isEqualTo: riderId);
    }

    final querySnapshot = await query.get();

    final baseOrders = querySnapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();

    final enriched = await Future.wait(baseOrders.map((order) async {
      // Fetch customer and tailor documents by ID
      DocumentSnapshot<Map<String, dynamic>> customerSnap =
          await _firestore.collection('customer').doc(order.customerId).get();

      DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
      if (order.tailorId != null && order.tailorId!.isNotEmpty) {
        tailorSnap = await _firestore.collection('tailor').doc(order.tailorId!).get();
      }

      final customerInfo = (customerSnap.exists && (customerSnap.data() != null))
          ? CustomerInfo.fromJson(customerSnap.data() as Map<String, dynamic>)
          : null;
      final tailorInfo = (tailorSnap != null && tailorSnap.exists && (tailorSnap.data() != null))
          ? TailorInfo.fromJson(tailorSnap.data() as Map<String, dynamic>)
          : null;

      return order.copyWith(customer: customerInfo, tailor: tailorInfo);
    }));

    return enriched;
  }

  Stream<List<OrderModel>> streamOrders(String status, String? riderId) {
    final col = _firestore.collection('order');
    Query<Map<String, dynamic>> query = col.where('status', isEqualTo: status);
    if (riderId != null) {
      query = query.where('rider_id', isEqualTo: riderId);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final baseOrders = snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();

      final enriched = await Future.wait(baseOrders.map((order) async {
        final customerSnap = await _firestore.collection('customer').doc(order.customerId).get();
        DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
        if (order.tailorId != null && order.tailorId!.isNotEmpty) {
          tailorSnap = await _firestore.collection('tailor').doc(order.tailorId!).get();
        }

        final customerInfo = (customerSnap.exists && (customerSnap.data() != null))
            ? CustomerInfo.fromJson(customerSnap.data() as Map<String, dynamic>)
            : null;
        final tailorInfo = (tailorSnap != null && tailorSnap.exists && (tailorSnap.data() != null))
            ? TailorInfo.fromJson(tailorSnap.data() as Map<String, dynamic>)
            : null;

        return order.copyWith(customer: customerInfo, tailor: tailorInfo);
      }));

      return enriched;
    });
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

  Future<void> completeOrder(String orderId) async {
    String currentRiderId=_instance.currentUser!.uid;
    try {
      await _firestore.collection('order').doc(orderId).update({
        'status': 'completed',
        'updated_at': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('driver').doc(currentRiderId).update({
        'is_assigned': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'completeOrder');
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    final String currentRiderId = _instance.currentUser!.uid;
    final orderRef = _firestore.collection('order').doc(orderId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);
        if (!snapshot.exists) {
          throw Exception('Order does not exist.');
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final String status = (data['status'] ?? '').toString();
        final dynamic rider = data['rider_id'];

        final bool alreadyAssigned = rider != null && rider.toString().isNotEmpty && rider.toString() != 'null';
        if (status != 'unassigned' || alreadyAssigned) {
          throw Exception('Order already accepted by another driver.');
        }

        transaction.update(orderRef, {
          'rider_id': currentRiderId,
          'status': 'assigned',
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      await _firestore.collection('driver').doc(currentRiderId).update({
        'is_assigned': 1,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'acceptOrder');
    } catch (e) {
      return false;
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('order').doc(orderId).get();
      if (!doc.exists) return null;
      final base = OrderModel.fromJson(doc.data() as Map<String, dynamic>);

      final customerSnap = await _firestore.collection('customer').doc(base.customerId).get();
      DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
      if (base.tailorId != null && base.tailorId!.isNotEmpty) {
        tailorSnap = await _firestore.collection('tailor').doc(base.tailorId!).get();
      }

      final customerInfo = (customerSnap.exists && (customerSnap.data() != null))
          ? CustomerInfo.fromJson(customerSnap.data() as Map<String, dynamic>)
          : null;
      final tailorInfo = (tailorSnap != null && tailorSnap.exists && (tailorSnap.data() != null))
          ? TailorInfo.fromJson(tailorSnap.data() as Map<String, dynamic>)
          : null;



      return base.copyWith(customer: customerInfo, tailor: tailorInfo);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'getOrderById');
    }
  }

}