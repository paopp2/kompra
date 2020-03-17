import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/ui/components/custom_icon_button.dart';
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:kompra/ui/components/rounded_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:kompra/domain/models/item.dart';
import 'package:provider/provider.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/components/back_icon_button.dart';

class SpecificItemScreen extends StatefulWidget {
  static String id = 'specific_item_screen_id';
  @override
  _SpecificItemScreenState createState() => _SpecificItemScreenState();
}

class _SpecificItemScreenState extends State<SpecificItemScreen> {
  Item chosenItem;
  int qty;
  double subtotal;
  String buttonTitle;

  @override
  void initState() {
    super.initState();
    chosenItem = Provider.of<ChosenItem>(context, listen: false).item;
    qty = 0;
    buttonTitle = 'Add to cart';
    Provider.of<MyGroceryCart>(context, listen: false).itemList.forEach((i) {
      if(i.itemName == Provider.of<ChosenItem>(context, listen: false).item.itemName) {
        Provider.of<MyGroceryCart>(context, listen: false).decrementItem(i);
        chosenItem = i;
        qty = i.quantity;
        buttonTitle = 'Update cart';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    subtotal = qty * chosenItem.itemPrice;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: constraints.maxHeight * 1/2,
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        height: constraints.maxHeight * 0.8/2,
                        child: Image(
                          image: CachedNetworkImageProvider(chosenItem.itemImageUrl),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: constraints.maxHeight * 1/2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 15,
                      ),
                      child: ListView(
                        children: <Widget>[
                          Container(
                            width: constraints.maxWidth * 0.9,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: FittedBox(
                                    child: AutoSizeText(
                                      chosenItem.itemName,
                                      style: TextStyle(
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth * 1/10,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: AutoSizeText(
                                      '${chosenItem.itemDetail}',
                                      style: TextStyle(
                                        fontSize: 50,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Text(
                                'Unit price',
                              ),
                              Spacer(),
                              Text(
                                '₱${chosenItem.itemPrice.toStringAsFixed(2)}',
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Text(
                                'Subtotal',
                              ),
                              Spacer(),
                              Text(
                                '₱${subtotal.toStringAsFixed(2)}',
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  '$qty ${chosenItem.itemUnit}/s',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              Spacer(),
                              MiniFAB(
                                icon: Icons.remove,
                                onPressed: () {
                                  setState(() {
                                    if(qty > 0) qty--;
                                  });
                                },
                              ),
                              MiniFAB(
                                icon: Icons.add,
                                onPressed: () {
                                  setState(() {
                                    qty++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                right: 20,
                left: 20,
                child: RoundedButton(
                  isDisabled: (qty == 0),
                  child: Text(
                    buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  colour: kDarkerAccentColor,
                  onPressed: () {
                    if(qty != 0) {
                      MyGroceryCart tempGroceryCart = Provider.of<MyGroceryCart>(context, listen: false);
                      chosenItem.setQuantityAndSubtotal(qty);
                      Provider.of<MyGroceryCart>(context, listen: false).addItem(chosenItem);
                      MyGroceryCart tempGroceryCart2 = Provider.of<MyGroceryCart>(context, listen: false);
                      for(var item in Provider.of<MyGroceryCart>(context, listen: false).itemList) {
                        print('${item.quantity} ${item.itemName} ${item.itemPrice}');
                      }
                      print('Totals: ${tempGroceryCart2.totalPrice} ${tempGroceryCart2.totalNum}');
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
//              Row(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 25,
                ),
                child: CustomIconButton(
                  constraints: constraints,
                  iconData: Icons.arrow_back,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
