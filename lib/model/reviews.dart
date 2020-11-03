import 'package:new_bos_app/model/clients.dart';
import 'package:new_bos_app/model/products.dart';

class Review {
  final int id;
  final String code;
  final String message;
  final int note;
  final String date;
  final Client client;
  final Product product;

  Review(
      {this.id,
      this.code,
      this.client,
      this.date,
      this.message,
      this.note,
      this.product});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.parse(json['id'].toString()),
      code: json['code'],
      note: int.parse(json['note']),
      client: Client.fromJson(json['client']),
      product: Product.fromJson(json['product']),
      date: json['date'],
      message: json['message'],
    );
  }

  Map<dynamic, String> toJson() => {
        'id': id.toString(),
        'code': code.toString(),
        'message': message.toString(),
        'client': client.toString(),
        'date': date.toString(),
        'note': note.toString(),
        'product': product.toString()
      };
}
