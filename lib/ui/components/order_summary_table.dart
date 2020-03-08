import 'package:flutter/material.dart';
import 'package:kompra/domain/models/item.dart';

class OrderSummaryTable extends StatelessWidget {
  const OrderSummaryTable({
    this.itemList,
    this.textColor = Colors.black,
  });

  final List<Item> itemList;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    List<DataRow> itemRows = [];
    for(var item in itemList) {
      DataRow tempRow = DataRow(
        cells: [
          DataCell(
            Text(
              item.itemName,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
          DataCell(
            Text(
              'x ${item.quantity}',
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
          DataCell(
            Text(
              '₱${item.subtotal}',
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ],
      );
      itemRows.add(tempRow);
    }
    return DataTable(
      headingRowHeight: 20,
      columns: [
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Qty',
            style: TextStyle(
              color: textColor,
            ),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Subtotal',
            style: TextStyle(
              color: textColor,
            ),
          ),
          numeric: true,
        ),
      ],
      rows: itemRows,
    );
  }
}