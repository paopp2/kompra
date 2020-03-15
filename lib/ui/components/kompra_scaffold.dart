import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:kompra/ui/components/menu_option_tile.dart';

class KompraScaffold extends StatelessWidget {
  const KompraScaffold({
    Key key,
    @required this.constraints,
    @required this.body,
    @required this.customAppbarRow,
    this.controller,
    this.menuOptions,
  }) : super(key: key);

  final BoxConstraints constraints;
  final Widget body;
  final Row customAppbarRow;
  final PanelController controller;
  final List<Widget> menuOptions;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: controller,
        defaultPanelState: PanelState.OPEN,
        isDraggable: false,
        maxHeight: constraints.maxHeight - 120,
        minHeight: constraints.maxHeight * 5/10,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        panel: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: Container(
            height: constraints.maxHeight * (8.5 / 10),
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: body,
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              color: kDarkerAccentColor,
              child: Padding(
                padding: EdgeInsets.only(
                  top: constraints.maxHeight * 1.5/10,
                  bottom: constraints.maxHeight * 5/10,
                  left: 15.0,
                  right: 15.0,
                ),
                child: Container(
                  child: (menuOptions!=null) ? ListView(
                    shrinkWrap: true,
                    children: menuOptions,
                  ): null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Container(
                height: constraints.maxHeight * 1.5 / 10,
                child: Center(
                  child: customAppbarRow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}