import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../providers/auth.dart';
import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  //var _showFavoritesOnly = false;

  //  String? tokenAuth;
  //  String? _userId;

  Auth? _auth;
  set setAuth(Auth? auth) {
    _auth = auth;
  }

  ProductsProvider();

  List<Product> get getProducts {
    // if (_showFavoritesOnly) {
    //   return _products.where((productItem) => productItem.isFavorite).toList();
    // }
    return [..._products];
  }

  List<Product> get getFavoriteProducts {
    return _products.where((productItem) => productItem.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // print('${_auth!['token']}');
    final filterString =
        filterByUser ? 'orderBy="userId"&equalTo="${_auth!.getUserId}"' : '';
    final url = Uri.parse(
        'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/products.json?auth=${_auth!.token}&$filterString');

    try {
      final response = await http.get(url);

      // print(json.decode(response.body));

      final Map<String, dynamic>? extractedProduct = json.decode(response.body);
      List<Product> loadedProducts = [];
      if (extractedProduct == null) {
        return;
      }

      final favoriteUrl = Uri.parse(
          'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/userFavorites/${_auth!.getUserId}.json?auth=${_auth!.token}');

      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedProduct.forEach((prodId, productData) {
        loadedProducts.add(Product(
          id: prodId,
          title: productData['title'],
          imageUrl: productData['imageUrl'],
          description: productData['description'],
          price: productData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });

      _products = loadedProducts;
      notifyListeners();
    } catch (error) {
      // print(error);
      throw (error);
    }
  }
  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product getProductById(String id) {
    return _products.firstWhere((product) {
      return product.id == id;
    });
  }

  void toggleFavoriteStatus(Product product) {
    product.isFavorite = !product.isFavorite;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    //final url = Uri.https('https://flutter-shop-app-ccbb0-default-rtdb.firebaseio.com', '/'products.json);
    final url = Uri.parse(
        'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/products.json?auth=${_auth!.token}');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'userId': _auth!.getUserId
          //'isFavorite': product.isFavorite,
        }),
      );
      print(json.decode(response.body));

      //_products.add(value);
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        imageUrl: product.imageUrl,
        description: product.description,
        price: product.price,
      );
      _products.add(newProduct);
      // _products.insert(0, newProduct); // at the start of list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    int productIndex = _products.indexWhere((pro) => pro.id == productId);

    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/products/$productId.json?auth=${_auth!.token}');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _products[productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> removeProduct(String productId) async {
    final url = Uri.parse(
        'https://flutter-http-app-7e966-default-rtdb.firebaseio.com/products/$productId.json?auth=${_auth!.token}');

    final existingProductIndex =
        _products.indexWhere(((product) => productId == product.id));
    Product? existingProduct = _products[existingProductIndex];

    _products.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
