class Promotion {
  final int proId;
  final int id;
  final String code;
  final String type;
  final int shopId;
  final int newPrice;
  final int isClose;
  final String beginingDate;
  final String endingDate;
  final String photo;

  Promotion(
      {this.proId,
      this.id,
      this.code,
      this.type,
      this.shopId,
      this.newPrice,
      this.isClose,
      this.beginingDate,
      this.endingDate,
      this.photo});

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
        proId: json['pro_id'] == null ? 0 : int.parse(json['pro_id']),
        id: int.parse(json['id'].toString()),
        code: json['code'],
        beginingDate: json['begining_date'],
        endingDate: json['ending_date'],
        isClose: int.parse(json['is_close']),
        newPrice: json['pro_id'] == null ? 0 : int.parse(json['new_price']),
        photo: json['photo'],
        shopId: int.parse(json['shop_id']),
        type: json['type']);
  }

  Map<dynamic, String> toJson() => {
        'pro_id': proId.toString(),
        'id': id.toString(),
        'code': code.toString(),
        'begining_date': beginingDate.toString(),
        'ending_date': endingDate.toString(),
        'is_close': isClose.toString(),
        'new_price': newPrice.toString(),
        'photo': photo.toString(),
        'shop_id': shopId.toString(),
        'type': type.toString(),
      };
}
