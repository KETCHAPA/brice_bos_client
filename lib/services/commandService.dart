import 'dart:io';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart' as globals;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/model/carts.dart';
import 'package:new_bos_app/model/commands.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Cart> storeCart(Map<String, dynamic> params) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('$endPoint/carts',
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return Cart.fromJson(data['data']);
    }
    print(response.statusCode.toString());
    throw Exception('Impossible de stocker le panier ${response.statusCode}');
  } catch (e) {
    throw Exception('Impossible de stocker le panier $e');
  }
}

Future<Command> storeCommand(Map<String, dynamic> params) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('$endPoint/commands',
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return Command.fromJson(data['data']);
    }

    throw Exception(
        'Impossible de stocker la commande ${response.statusCode} - ${response.body.toString()}');
  } catch (e) {
    throw Exception('Impossible de stocker la commande $e');
  }
}

Future fetchWaitingCommands(String code) async {
  try {
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/clients/$code/waitingCommands',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      }
    }
    throw Exception(
        'Impossible de recuperer les commandes en attente ${response.statusCode}');
  } catch (e) {
    throw Exception('Impossible de recuperer les commandes en attente $e');
  }
}

Future fetchProcessedCommands(String code) async {
  try {
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/clients/$code/validateCommands',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      }
    }
    throw Exception(
        'Impossible de recuperer les commandes en attente ${response.statusCode}');
  } catch (e) {
    throw Exception('Impossible de recuperer les commandes en attente $e');
  }
}

Future fetchRejectedCommands(String code) async {
  try {
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/clients/$code/rejectedCommands',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      }
    }
    throw Exception(
        'Impossible de recuperer les commandes en attente ${response.statusCode}');
  } catch (e) {
    throw Exception('Impossible de recuperer les commandes en attente $e');
  }
}

Future fetchOnRoadCommands(String code) async {
  try {
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/clients/$code/closeCommands',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        print('success');
        return data['data'];
      }
    }
    throw Exception(
        'Impossible de recuperer les commandes en route ${response.statusCode}');
  } catch (e) {
    throw Exception('Impossible de recuperer les commandes en route $e');
  }
}

Future fetchAllCommands(String code) async {
  try {
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/clients/$code/allCommands',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      }
    }
    throw Exception('Impossible de recuperer les commandes ${response.body}');
  } catch (e) {
    throw Exception('Impossible de recuperer les commandes $e');
  }
}

Future<bool> sendRecapMail(String code) async {
  try {
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/commands/$code/mailRecap',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['success'];
    }
    throw Exception(
        'Impossible d\'envoyer le mail recapitulatif ${response.body}');
  } catch (e) {
    throw Exception('Exception $e');
  }
}
