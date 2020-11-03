class Product {
  final int id;
  final String code;
  final String name;
  final String description;
  final int oldPrice;
  final int newPrice;
  final String photo;
  final int available;
  final String shopName;
  final int shopId;
  final String type;
  final int rate;

  Product(
      {this.id,
      this.code,
      this.name,
      this.description,
      this.oldPrice,
      this.newPrice,
      this.photo,
      this.shopId,
      this.available,
      this.rate,
      this.shopName,
      this.type});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: int.parse(json['id'].toString()),
        code: json['code'],
        name: json['name'],
        description: json['description'],
        oldPrice: int.parse(json['old_price']),
        newPrice: json['new_price'] == null ? 0 : int.parse(json['new_price']),
        photo: json['photo'],
        available: int.parse(json['available']),
        rate: int.parse(json['rate']),
        shopName: json['shop_name'],
        type: json['type'],
        shopId: int.parse(json['shop_id']));
  }

  Map<dynamic, String> toJson() => {
        'id': id.toString(),
        'code': code.toString(),
        'name': name.toString(),
        'description': description,
        'old_price': oldPrice.toString(),
        'new_price': newPrice.toString(),
        'photo': photo.toString(),
        'available': available.toString(),
        'shop_name': shopName.toString(),
        'shop_id': shopId.toString(),
        'type': type.toString(),
        'rate': rate.toString(),
      };
}
