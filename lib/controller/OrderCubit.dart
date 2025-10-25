import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_driver/data/models/order_item_details.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/data/repository/order_repo.dart';

import '../helper/firebase_error_handler.dart';

class OrderState extends Equatable {
  final bool isLoading;
  final List<OrderModel> orders;
  final OrderModel? currentOrder;
  final String? errorMessage;
  final OrderModel? selectedOrder;

  const OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.errorMessage,
    this.selectedOrder,
    this.currentOrder,
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? errorMessage,
    OrderModel? selectedOrder,
    OrderModel? currentOrder,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      currentOrder: currentOrder ?? this.currentOrder,
    );
  }

  @override
  List<Object?> get props => [isLoading, orders, errorMessage, selectedOrder, currentOrder];
}

class OrderCubit extends Cubit<OrderState> {
  final DriverOrderRepository _orderRepository;

  OrderCubit({required DriverOrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderState());

  Future<void> fetchCurrentOrder() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      String userId=FirebaseAuth.instance.currentUser!.uid;
      final orders = await _orderRepository.fetchOrders('assigned',userId); // Fetch all orders
      final currentOrder = orders.isNotEmpty ? orders.first : null;
      emit(state.copyWith(
        isLoading: false,
        currentOrder: currentOrder,
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

  Future<void> acceptOrder(String orderId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      bool success = await _orderRepository.acceptOrder(orderId);
      if (success) {
        // Refresh the unassigned orders list
        await fetchUnAssignedOrders();
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to accept order',
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'acceptOrder'),
      ));
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// 🔹 Select an order (for order detail screen)
  void selectOrder(OrderModel order) {
    emit(state.copyWith(selectedOrder: order));
  }

  void updateOrderStatus(String orderId, String newStatus) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _orderRepository.updateOrderStatus(orderId, newStatus);
      // Update the local state
      final updatedOrders = state.orders.map((order) {
        if (order.orderId == orderId) {
          return order.copyWith(status: newStatus);
        }
        return order;
      }).toList();

      emit(state.copyWith(
        isLoading: false,
        orders: updatedOrders,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'updateOrderStatus'),
      ));
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
  /// 🔹 Refresh order details for selected order


  /// 🔹 Clear state (for logout or refresh)
  void clearOrders() {
    emit(const OrderState());
  }
}
