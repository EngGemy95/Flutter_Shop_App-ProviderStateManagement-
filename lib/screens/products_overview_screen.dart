import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products_provider.dart';
import '../widgets/badge.dart';

import '../widgets/product_grid.dart';

enum FilterOptions {
  Favorite,
  All,
  Cart,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorite = false;
  var _isInit = true;
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future.delayed(Duration.zero).then((value) {
    //   Provider.of<ProductsProvider>(context, listen: false)
    //       .fetchAndSetProducts();
    // });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          isLoading = false;
        });
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer =
    //    Provider.of<ProductsProvider>(context, listen: false);

//final cart = Provider.of<Cart>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          PopupMenuButton(
            onSelected: (selectedValue) {
              setState(() {
                switch (selectedValue) {
                  case FilterOptions.Favorite:
                    {
                      _showOnlyFavorite = true;
                      //productsContainer.showFavoritesOnly();
                      break;
                    }
                  case FilterOptions.All:
                    {
                      _showOnlyFavorite = false;
                      //productsContainer.showAll();
                      break;
                    }
                  case FilterOptions.Cart:
                    {
                      break;
                    }
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.Favorite,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (context, cart, ch) => Badge(
              child: ch!,
              //value: cart.totalSubItemsCount.toString(),
              value: cart.itemsCount.toString(),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : productGrid(_showOnlyFavorite),
      drawer: AppDrawer(),
    );
  }
}
