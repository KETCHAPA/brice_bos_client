class Cart {
  final int id;
  final String code;
  final String productsId;
  final String quantities;
  final int amount;

  Cart({this.id, this.code, this.productsId, this.amount, this.quantities});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
        id: json['id'],
        code: json['code'],
        productsId: json['products_id'],
        quantities: json['quantities'],
        amount: int.parse(json['amount']));
  }
}
