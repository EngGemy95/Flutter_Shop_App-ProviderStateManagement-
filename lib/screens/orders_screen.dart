import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatelessWidget {
  OrdersScreen({Key? key}) : super(key: key);
  //bool _isInit = true;

  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    //حذفنا ده علشان ميدخلش فى لوب مالا نهايه
    //final ordersData = Provider.of<Orders>(context);

    // احنا استخدمنا الفيوتشر بلدر وخلينا الويدجت ستاتليس بدل ما تبقى ستاتفل ويدجت واستخدمنا الكونسيومر

    // لو نفترض لو عندنا حاجه داخل الويدجت هتحتاج اننا نخليها استاتفل
    // فا بدل ما كل شويه هنعمل ريبلد ونبعت ريكويست للسيرفر
    // هنخزن الداتا فى متغير ونستدعيه فى الفيوتشر بتاع الفيوتشر بيلدر

    //Future _ordersFuture;

    // Future _obtainOrdersFuture() {
    //   return Provider.of<Orders>(context, listen: false).fetchOrders();
    // }

    // @override
    // void initState() {
    //    TODO: implement initState
    //   super.initState();
    //    _ordersFuture = _obtainOrdersFuture();
    // }

    // body: FutureBuilder(
    //    future: _ordersFuture,

    return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: Provider.of<Orders>(context, listen: false).fetchOrders(),
            builder: (ctx, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshots.error != null) {
                return Center(
                  child: Text('Error in fetching orders!'),
                );
              } else {
                return Consumer<Orders>(builder: (ctx, ordersData, child) {
                  return ordersData.orders.isEmpty
                      ? Center(
                          child: Text('No orders Exist!'),
                        )
                      : ListView.builder(
                          itemCount: ordersData.orders.length,
                          itemBuilder: (ctx, index) {
                            return OrderItem(ordersData.orders[index]);
                          });
                });
              }
            }));
  }
}
