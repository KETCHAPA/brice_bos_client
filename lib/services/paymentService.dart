import 'dart:io';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/model/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Service> storeCommandServices(Map<String, dynamic> params, code) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('$endPoint/command/$code/service',
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return Service.fromJson(data['data']);
    }
    print(response.statusCode);
    throw Exception('Impossible d\'ajouter ce service a la commande');
  } catch (e) {
    throw Exception('Impossible d\'ajouter ce service a la commande');
  }
}

Future<List> getPaymentWay(int id) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.get('$endPoint/payment/$id',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      Iterable items = data['data'];
      return items;
    }

    print(response.body);
    throw Exception('Impossible de recuperer les modes de paiement');
  } catch (e) {
    throw Exception('Impossible de recuperer les modes de paiement');
  }
}

Future<List> getLivraisonWay(int id) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.get('$endPoint/livraison/$id',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      Iterable items = data['data'];
      return items;
    }

    print(response.statusCode);
    throw Exception('Impossible de recuperer les modes de livraison');
  } catch (e) {
    throw Exception('Impossible de recuperer les modes de livraison');
  }
}
