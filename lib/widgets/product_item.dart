import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  // const ProductItem({
  //   Key? key,
  //   required this.id,
  //   required this.title,
  //   required this.imageUrl,
  // }) : super(key: key);

  // final String id;
  // final String title;
  // final String imageUrl;

  //final int index;
  //ProductItem(this.index);

  @override
  Widget build(BuildContext context) {
    // final productProviders =
    //     Provider.of<ProductsProvider>(context, listen: false);
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    print('Rebuild....');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
            //   return ProductDetailsScreen();
            // }));
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/loading.gif',
              image: product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              onPressed: () async {
                try {
                  final isFavorite = await product.toggleFavoriteStatus(
                      auth.token!, auth.getUserId!);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  isFavorite
                      ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Item added to favorite successfully.'),
                          ),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Item removed from favorite successfully.'),
                          ),
                        );
                } catch (error) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error in removing item from favorite!'),
                    ),
                  );
                }
              },
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added item to cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: Theme.of(context).textTheme.headline6!.color,
                    onPressed: () {
                      cart.removeSingleCartITem(product.id);
                    },
                  ),
                ),
              );
            },
            icon: Icon(
              //cart.itemIsExist(product.id)
              //  ?
              Icons.shopping_cart,
              //:
              // Icons.shopping_cart_outlined
            ),
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
