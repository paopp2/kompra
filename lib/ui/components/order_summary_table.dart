import 'package:flutter/material.dart';
import 'package:kompra/domain/models/item.dart';

class OrderSummaryTable extends StatelessWidget {
  const OrderSummaryTable({
    this.itemList,
  });

  final List<Item> itemList;

  @override
  Widget build(BuildContext context) {
    List<DataRow> itemRows = [];
    for(var item in itemList) {
      DataRow tempRow = DataRow(
        cells: [
          DataCell(
            Text(
                item.itemName
            ),
          ),
          DataCell(
            Text(
                'x ${item.quantity}'
            ),
          ),
          DataCell(
            Text(
                '₱${item.subtotal}'
            ),
          ),
        ],
      );
      itemRows.add(tempRow);
    }
    return DataTable(
      headingRowHeight: 30,
      columns: [
        DataColumn(
          label: Text('Name'),
        ),
        DataColumn(
          label: Text('Qty'),
          numeric: true,
        ),
        DataColumn(
          label: Text('Subtotal'),
          numeric: true,
        ),
      ],
      rows: itemRows,
    );
  }
}