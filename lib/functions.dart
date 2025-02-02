
String generateOrderId(List<Map<String, dynamic>> ordersList) {
  int lastOrderIdNum = 0;
  if (ordersList.isNotEmpty) {
    final lastOrderId = ordersList.last['OrderId'] as String;
    final orderIdSuffix = int.tryParse(lastOrderId.replaceAll(RegExp(r'\D'), '')) ?? 0;
    lastOrderIdNum = orderIdSuffix + 1;
  }
  return 'Rest100125${lastOrderIdNum.toString().padLeft(8, '0')}';
}

void confirmOrder(List<Map<String, dynamic>> ordersList, List<Map<String, dynamic>> cartList, Function setState) {
  int currentOrderNum = ordersList.isNotEmpty ? ordersList.last['OrderNum'] : 0;
  int newOrderNum = currentOrderNum + 1;
  num orderTotal = cartList.fold<num>(0, (num sum, item) => sum + (item['quantity'] * item['price']));

  setState(() {
    ordersList.add({
      'OrderNum': newOrderNum,
      'OrderId': generateOrderId(ordersList),
      'Amount': orderTotal,
      'Status': 'Active',
    });
    cartList.clear();
  });
}

void fetchUpdatedOrdersList(Function setState, List<Map<String, dynamic>> ordersList) {
  setState(() {
    ordersList = List.from(ordersList);
  });
}