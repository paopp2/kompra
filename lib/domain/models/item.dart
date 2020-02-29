
class Item {
  Item({
    this.itemName,
    this.itemDetail,
    this.itemCode,
    this.itemImageUrl,
    this.itemUnit,
    this.itemPrice,
    this.quantity,
  });

  final String itemName;
  final String itemDetail;
  final String itemCode;
  final String itemImageUrl;
  final String itemUnit;
  final double itemPrice;
  int quantity;
  double subtotal;

  void setQuantityAndSubtotal(int qty) {
    quantity = qty;
    subtotal = itemPrice * qty;
  }
}