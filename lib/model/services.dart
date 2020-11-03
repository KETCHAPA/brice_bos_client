class Service {
  final int id;
  final int serviceId;
  final int importance;
  final int commandId;

  Service({this.id, this.commandId, this.importance, this.serviceId});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
        id: json['id'],
        serviceId: int.parse(json['ser_id']),
        importance: int.parse(json['importance']),
        commandId: json['com_id']);
  }
}
