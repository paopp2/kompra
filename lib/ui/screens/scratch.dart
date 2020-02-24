import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class ScratchScreen extends StatefulWidget {
  static String id = 'scratch_screen';

  @override
  _ScratchScreenState createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  bool value = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(
                label: Text('Qty'),
              ),
              DataColumn(
                label: Text('Item'),
              )
            ],
            rows: [
              DataRow(
                cells: [
                  DataCell(
                    Text('2'),
                  ),
                  DataCell(
                    Text('Nissan Noodles'),
                  )
                ],
                selected: value,
                onSelectChanged: (selected) {
                  setState(() {
                    value = selected;
                  });
                }
              ),
              DataRow(
                  cells: [
                    DataCell(
                      Text('7'),
                    ),
                    DataCell(
                      Text('Cabbage and Lettuce shit alskjdfdjl;kasjfdl;askjdfl;kasjdfl;kasjkdfdjdjl;f'),
                    )
                  ],
                  selected: value,
                  onSelectChanged: (selected) {
                    setState(() {
                      value = selected;
                    });
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
