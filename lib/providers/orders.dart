import 'dart:convert';

import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import '../providers/cart.dart';

class OrderITem {
  final String id;
  final List<CartItem> products;
  final double total;
  final DateTime dateTime;

  OrderITem({
    required this.id,
    required this.products,
    required this.total,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  Orders();

  List<OrderITem> _orders = [];
  Auth? _auth;

  List<OrderITem> get orders {
    return [..._orders];
  }

  set setAuth(Auth? auth) {
    _auth = auth;
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/orders/${_auth!.getUserId}.json?auth=${_auth!.token}');

    final response = await http.get(url);
    print(json.decode(response.body));

    final Map<String, dynamic>? extractedOrders = json.decode(response.body);
    List<OrderITem> loadedOrders = [];
    if (extractedOrders == null) {
      _orders.clear();
      return;
    }

    extractedOrders.forEach((orderId, orderData) {
      print(orderData['products']);
      loadedOrders.add(OrderITem(
          id: orderId,
          total: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ))
              .toList()));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProdcuts, double total) async {
    final timeStamp = DateTime.now();

    final url = Uri.parse(
        'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/orders/${_auth!.getUserId}.json?auth=${_auth!.token}');

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProdcuts
              .map((item) => {
                    'id': item.id,
                    'title': item.title,
                    'quantity': item.quantity,
                    'price': item.price,
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderITem(
          id: json.decode(response.body)['name'],
          products: cartProdcuts,
          total: total,
          dateTime: timeStamp,
        ));

    notifyListeners();
  }
}
