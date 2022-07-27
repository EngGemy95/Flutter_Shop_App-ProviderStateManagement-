import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/Edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products_provider.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key? key}) : super(key: key);

  static const String routeName = '/user-product';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add)),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () {
                      return _refreshProducts(context);
                    },
                    child: Consumer<ProductsProvider>(
                      builder: (cx, productsData, child) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsData.getProducts.length,
                            itemBuilder: (ctx, index) {
                              // return ChangeNotifierProvider.value(
                              //   value: productsData.getProducts[index],
                              //   child:
                              return UserProductItem(
                                productsData.getProducts[index].id,
                                productsData.getProducts[index].title,
                                productsData.getProducts[index].imageUrl,
                                //   ),
                              );
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }
}
