import 'dart:math';

import 'package:flutter/material.dart';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  const OrderItem(this.orderItem, {Key? key}) : super(key: key);

  final ord.OrderITem orderItem;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: _expanded
          ? min(widget.orderItem.products.length * 20.0 + 110, 200)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$ ${widget.orderItem.total}'),
              subtitle: Text(DateFormat('dd/MM/yyyy  hh:mm')
                  .format(widget.orderItem.dateTime)),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  icon:
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more)),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: _expanded
                  ? min(widget.orderItem.products.length * 20.0 + 10, 100)
                  : 0,
              child: ListView.builder(
                  itemCount: widget.orderItem.products.length,
                  itemBuilder: (ctx, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.orderItem.products[index].title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$ ${widget.orderItem.products[index].quantity}x  \$ ${widget.orderItem.products[index].price}',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        )
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
