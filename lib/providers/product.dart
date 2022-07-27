import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    this.isFavorite = false,
  });

  Future<dynamic> toggleFavoriteStatus(String? tokenAuth, String userId) async {
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final url = Uri.parse(
          'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$tokenAuth');

      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        throw HttpException('Error!');
      }
      return isFavorite;
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
