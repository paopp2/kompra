import 'package:flutter/material.dart';
import 'package:kompra/domain/models/item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/specific_item_screen.dart';
import 'package:provider/provider.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    this.item,
    this.constraints,
  });

  final BoxConstraints constraints;
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10,
            ),
            child: Card(
              elevation: 5,
              color: Colors.blueGrey[50],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Provider.of<ChosenItem>(context, listen: false).item = item;
                  Navigator.pushNamed(context, SpecificItemScreen.id);
                },
                splashColor: Colors.green[100],
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0, 10, 10, 0),
                      child: Container(
                        height: constraints.maxHeight * 1 / 12,
                        child: ListTile(
                          title: Text(
                            item.itemName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                              item.itemDetail
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          15, 0, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '₱${item.itemPrice.toStringAsFixed(2)}/${item.itemUnit}',
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: (item.quantity > 0) ? Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  color: Colors.green[500],
                                ),
                              ) : Icon(
                                Icons.add,
                                color: Colors.green[500],
                              ),
                              backgroundColor: Colors.green[100] ,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: constraints.maxHeight * 1 / 8.5,
              child: CachedNetworkImage(
                imageUrl: item.itemImageUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}