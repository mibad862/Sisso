import '../../entities/order_delivery_date.dart';

import 'cart_mixin.dart';

mixin OrderDeliveryMixin on CartMixin {
  OrderDeliveryDate? selectedDate;
  OrderDeliveryTimeSlot? selectedTimeSlot;
  Map<String, OrderDeliveryDate> selectedDateByStoreId = {};

  void setOrderDeliveryDate(OrderDeliveryDate ordd) {
    selectedDate = ordd;
    selectedTimeSlot = ordd.selectedTimeSlot;
  }

  void setOrderDeliveryDateByStoreId(OrderDeliveryDate ordd, String id) {
    selectedDateByStoreId[id] = ordd;
  }

  void clearOrderDeliveryDate() {
    selectedDate = null;
    selectedTimeSlot = null;
    selectedDateByStoreId.clear();
  }

  void setOrderDeliveryTimeSlot(OrderDeliveryTimeSlot? slot) {
    selectedTimeSlot = slot;
    selectedDate?.selectedTimeSlot = slot;
  }
}
