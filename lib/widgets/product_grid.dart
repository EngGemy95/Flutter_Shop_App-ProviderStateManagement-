import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class productGrid extends StatelessWidget {
  const productGrid(
    this.showFavorite, {
    Key? key,
  }) : super(key: key);

  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final productsList = showFavorite
        ? productsData.getFavoriteProducts
        : productsData.getProducts;

    return productsList.isEmpty && showFavorite
        ? Center(child: const Text('No Favorite Product Exist!'))
        : productsList.isEmpty && !showFavorite
            ? Center(child: const Text('No Product Exist!'))
            : GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: productsList.length,
                itemBuilder: (ctx, index) {
                  // We use ChangeNotifierProvider.value  in List  or GridView is the best
                  return ChangeNotifierProvider.value(
                    value: productsList[index],
                    // We do not need to pass data through constructor as we get data from provider
                    child: ProductItem(
                        //index,
                        // id: productsList[index].id,
                        // title: productsList[index].title,
                        // imageUrl: productsList[index].imageUrl,
                        ),
                  );
                });
  }
}
