class Payment {
  final int id;
  final String code;
  final String name;

  Payment({this.code, this.id, this.name});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(code: json['code'], id: json['id'], name: json['name']);
  }
}
