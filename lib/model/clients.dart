class Client {
  final int id;
  final String code;
  final String address;
  final String name;
  final String email;
  final String phone;
  final String town;
  final String street;
  final String photo;
  final String country;
  final String password;
  final String createdAt;
  final String updatedAt;

  Client(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.code,
      this.town,
      this.street,
      this.country,
      this.photo,
      this.password,
      this.createdAt,
      this.updatedAt});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        address: json['address'],
        town: json['town'],
        country: json['country'],
        street: json['street'],
        password: json['password'],
        code: json['code'],
        phone: json['phone'],
        photo: json['photo'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at']);
  }
}
