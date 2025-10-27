import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/data/repository/order_repo.dart';

import '../helper/firebase_error_handler.dart';

class OrderState extends Equatable {
  final bool isLoading;
  final List<OrderModel> orders;
  final OrderModel? currentOrder;
  final String? errorMessage;
  final OrderModel? selectedOrder;
  final int todaysOrderCount;
  final int totalOrderCount;
  final int weeklyOrderCount;
  const OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.errorMessage,
    this.selectedOrder,
    this.currentOrder,
    this.todaysOrderCount=2,
    this.weeklyOrderCount=5,
    this.totalOrderCount=20,
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? errorMessage,
    OrderModel? selectedOrder,
    OrderModel? currentOrder,
    bool clearCurrentOrder = false,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      currentOrder: clearCurrentOrder ? null : (currentOrder ?? this.currentOrder),
    );
  }

  @override
  List<Object?> get props => [isLoading, orders, errorMessage, selectedOrder, currentOrder];
}

class OrderCubit extends Cubit<OrderState> {
  final DriverOrderRepository _orderRepository;
  StreamSubscription<List<OrderModel>>? _unassignedSub;
  StreamSubscription<List<OrderModel>>? _assignedSub;

  OrderCubit({required DriverOrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderState());

  // Subscribe to unassigned orders in realtime
  void subscribeToUnassignedOrders() {
    // start loading
    emit(state.copyWith(isLoading: true, errorMessage: null));
    _unassignedSub?.cancel();
    _unassignedSub = _orderRepository
        .streamOrders('unassigned', null)
        .listen((orders) {
      emit(state.copyWith(isLoading: false, orders: orders, errorMessage: null));
    }, onError: (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    });
  }

  // Subscribe to current driver's assigned order in realtime
  void subscribeToCurrentOrder() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(isLoading: false, clearCurrentOrder: true));
      return;
    }
    _assignedSub?.cancel();
    _assignedSub = _orderRepository
        .streamOrders('assigned', user.uid)
        .listen((orders) {
      final current = orders.isNotEmpty ? orders.first : null;
      emit(state.copyWith(
        isLoading: false,
        currentOrder: current,
        clearCurrentOrder: current == null,
      ));
    }, onError: (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    });
  }

  Future<void> fetchCurrentOrder() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      String userId=FirebaseAuth.instance.currentUser!.uid;
      final orders = await _orderRepository.fetchOrders('assigned',userId); // Fetch all orders
      final currentOrder = orders.isNotEmpty ? orders.first : null;
      emit(state.copyWith(
        isLoading: false,
        currentOrder: currentOrder,
        clearCurrentOrder: currentOrder == null,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'fetchCurrentOrder'),
      ));
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }



  /// 🔹 Fetch all orders (with order_details)
  Future<void> fetchUnAssignedOrders() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final orders = await _orderRepository.fetchOrders('unassigned', null);

      emit(state.copyWith(
        isLoading: false,
        orders: orders,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'fetchUnAssignedOrders'),
      ));
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      bool success = await _orderRepository.acceptOrder(orderId);
      if (success) {
        // Refresh the unassigned list and current order
        final futures = await Future.wait([
          _orderRepository.fetchOrders('unassigned', null),
          _orderRepository.fetchOrders('assigned', FirebaseAuth.instance.currentUser!.uid),
        ]);
        final unassigned = futures[0];
        final assigned = futures[1];
        final current = assigned.isNotEmpty ? assigned.first : null;

        emit(state.copyWith(
          isLoading: false,
          orders: unassigned,
          currentOrder: current,
          clearCurrentOrder: current == null,
        ));
        return true;
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to accept order',
        ));
        return false;
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'acceptOrder'),
      ));
      return false;
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  /// 🔹 Select an order (for order detail screen)
  void selectOrder(OrderModel order) {
    emit(state.copyWith(selectedOrder: order));
  }

  /// Load a single order by ID and set as selected
  Future<void> loadOrderById(String orderId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final order = await _orderRepository.getOrderById(orderId);
      emit(state.copyWith(isLoading: false, selectedOrder: order));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'loadOrderById'),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Update order status and reflect in orders, selectedOrder, and currentOrder
  void updateOrderStatus(String orderId, String newStatus) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _orderRepository.updateOrderStatus(orderId, newStatus);
      // Update collections
      final updatedOrders = state.orders.map((order) {
        if (order.orderId == orderId) {
          return order.copyWith(status: newStatus);
        }
        return order;
      }).toList();

      // Update selected/current if matching
      final updatedSelected = (state.selectedOrder != null && state.selectedOrder!.orderId == orderId)
          ? state.selectedOrder!.copyWith(status: newStatus)
          : state.selectedOrder;

      final updatedCurrent = (state.currentOrder != null && state.currentOrder!.orderId == orderId)
          ? state.currentOrder!.copyWith(status: newStatus)
          : state.currentOrder;

      emit(state.copyWith(
        isLoading: false,
        orders: updatedOrders,
        selectedOrder: updatedSelected,
        currentOrder: updatedCurrent,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'updateOrderStatus'),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Complete selected order: set backend to completed and free driver assignment
  Future<void> completeSelectedOrder() async {
    final sel = state.selectedOrder;
    if (sel == null) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _orderRepository.completeOrder(sel.orderId);
      // Reflect completion in all views
      final updatedOrders = state.orders.map((o) =>
          o.orderId == sel.orderId ? o.copyWith(status: 'completed') : o).toList();

      final updatedSelected = sel.copyWith(status: 'completed');

      // Clear current order if it was the same
      final updatedCurrent = (state.currentOrder != null && state.currentOrder!.orderId == sel.orderId)
          ? null
          : state.currentOrder;

      emit(state.copyWith(
        isLoading: false,
        orders: updatedOrders,
        selectedOrder: updatedSelected,
        currentOrder: updatedCurrent,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'completeSelectedOrder'),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// 🔹 Clear state (for logout or refresh)
  void clearOrders() {
    emit(const OrderState());
  }

  @override
  Future<void> close() {
    _unassignedSub?.cancel();
    _assignedSub?.cancel();
    return super.close();
  }
}
