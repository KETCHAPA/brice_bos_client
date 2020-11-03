class Category {
  final int id;
  final String code;
  final String name;
  final String description;
  final int catId;
  final int priority;
  final String photo;

  Category(
      {this.id,
      this.code,
      this.name,
      this.description,
      this.catId,
      this.priority,
      this.photo});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: int.parse(json['id'].toString()),
        code: json['code'],
        name: json['name'],
        description: json['description'],
        priority: int.parse(json['priority']),
        photo: json['photo']);
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'code': code.toString(),
        'name': name.toString(),
        'description': description.toString(),
        'priority': priority.toString(),
        'photo': photo.toString()
      };
}
