import 'package:new_bos_app/model/clients.dart';
import 'package:new_bos_app/model/commands.dart';
import 'package:new_bos_app/model/shops.dart';

class Discount {
  final int id;
  final String code;
  final Client client;
  final Command command;
  final int amount;
  final Shop shop;
  final String deadDate;
  final String reason;

  Discount(
      {this.id,
      this.code,
      this.amount,
      this.client,
      this.command,
      this.deadDate,
      this.reason,
      this.shop});

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
        id: int.parse(json['id'].toString()),
        code: json['code'],
        amount: int.parse(json['amount']),
        client: Client.fromJson(json['client']),
        command: Command.fromJson(json['command']),
        deadDate: json['dead_date'],
        reason: json['reason'],
        shop: Shop.fromJson(json['shop']));
  }

  Map<dynamic, String> toJson() => {
        'id': id.toString(),
        'code': code.toString(),
        'amount': amount.toString(),
        'client': client.toString(),
        'shop': shop.toString(),
        'command': command.toString(),
        'dead_date': deadDate.toString(),
        'reason': reason.toString(),
      };
}
