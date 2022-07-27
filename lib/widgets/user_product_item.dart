import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../screens/Edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  const UserProductItem(this.product_id, this.title, this.imageUrl, {Key? key})
      : super(key: key);

  final String product_id;
  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final scaffoldMessangerContext = ScaffoldMessenger.of(context);

    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          EditProductScreen.routeName,
                          arguments: product_id);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    )),
                IconButton(
                    onPressed: () async {
                      try {
                        await Provider.of<ProductsProvider>(context,
                                listen: false)
                            .removeProduct(product_id);
                        scaffoldMessangerContext.removeCurrentSnackBar();
                        scaffoldMessangerContext.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Deleted Successfully.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } catch (error) {
                        scaffoldMessangerContext.removeCurrentSnackBar();
                        scaffoldMessangerContext.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Deleted Faild!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).errorColor,
                    )),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
