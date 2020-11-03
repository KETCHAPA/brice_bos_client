import 'dart:io';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/model/clients.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future cashOut(Map<String, dynamic> params) async {
  try {
    final response = await http.post('$endPoint/cashout', body: params);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['data'];
    }

    print(response.statusCode);
    throw Exception(
        'Impossible de cashOut l\'argent de vos commandes ${response.body}');
  } catch (e) {
    throw Exception('Exception $e');
  }
}

Future cashIn(Map<String, dynamic> params) async {
  try {
    final response = await http.post('$endPoint/cashin', body: params);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['data'];
    }

    print(response.statusCode);
    throw Exception(
        'Impossible de cashIn l\'argent de vos commandes ${response.body}');
  } catch (e) {
    throw Exception('Exception $e');
  }
}

Future<Client> getSalerInfo(int id) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.get('$endPoint/saler/$id',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      Client client = Client.fromJson(data['data']);
      return client;
    }

    print(response.statusCode);
    throw Exception('Impossible de recuperer les informations du beneficiaire');
  } catch (e) {
    throw Exception('Exception $e');
  }
}
