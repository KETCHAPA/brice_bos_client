class Shop {
  final int id;
  final String code;
  final String name;
  final String description;
  final int rate;
  final String photo;
  final int nbrOfProducts;
  Shop(
      {this.id,
      this.code,
      this.name,
      this.description,
      this.rate,
      this.photo,
      this.nbrOfProducts});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
        id: int.parse(json['id'].toString()),
        code: json['code'],
        name: json['name'],
        description: json['description'],
        rate: int.parse(json['rate']),
        nbrOfProducts: int.parse(json['nbrOfProducts'].toString()),
        photo: json['photo']);
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'code': code.toString(),
        'name': name.toString(),
        'description': description.toString(),
        'rate': rate.toString(),
        'photo': photo.toString(),
        'nbrOfProducts': nbrOfProducts.toString()
      };
}
