class Command {
  final int id;
  final String code;
  final String paymentWay;
  final String workflow;
  final String shopId;
  final int cartId;
  final int clientId;
  Command(
      {this.id,
      this.shopId,
      this.code,
      this.clientId,
      this.cartId,
      this.paymentWay,
      this.workflow});

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      id: json['id'],
      code: json['code'],
      clientId: int.parse(json['client_id']),
      cartId: int.parse(json['cart_id']),
      shopId: json['shop_id']
    );
  }
}
