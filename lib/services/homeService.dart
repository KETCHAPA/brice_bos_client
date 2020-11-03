import 'package:new_bos_app/common/ENDPOINT.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/clients.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/model/promotions.dart';
import 'package:new_bos_app/model/shops.dart';

Future<List<Category>> fetchMainCategory() async {
  try {
    final response = await http.get('$endPoint/mainCategory');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable data = res['data'];
      return data.map((model) => Category.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      throw Exception(
          'Impossible de recuperer les categories principales ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Impossible de recuperer les categories principales $e');
  }
}

Future<List<Product>> fetchDailyDeals() async {
  try {
    final response = await http.get('$endPoint/dailyDeals');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Product.fromJson(item)).toList();
    } else {
      print(response.statusCode);
      throw Exception(
          'Impossible de recuperer les offres du jour ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Impossible de recuperer les offres du jour $e');
  }
}

Future<List<Product>> fetchFlashSales() async {
  try {
    final response = await http.get('$endPoint/flashSales');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable data = res['data'];
      return data.map((model) => Product.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      throw Exception(
          'Impossible de recuperer les ventes flash principales ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Impossible de recuperer les ventes flash principales $e');
  }
}

Future<List<Shop>> fetchShops() async {
  try {
    final response = await http.get('$endPoint/shops');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable data = res['data'];
      return data.map((model) => Shop.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      throw Exception(
          'Impossible de recuperer les boutiques ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Impossible de recuperer les boutiques $e');
  }
}

Future<List<Promotion>> fetchBanners() async {
  try {
    final response = await http.get('$endPoint/banners');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Promotion.fromJson(item)).toList();
    } else {
      print(response.statusCode);
      throw Exception(
          'Impossible de recuperer les bannieres ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Impossible de recuperer les bannieres $e');
  }
}

Future<List<Client>> fetchUsers() async {
  try {
    final response = await http.get('$endPoint/users');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Client.fromJson(item)).toList();
    } else {
      print(response.statusCode);
      throw Exception(
          'Impossible de recuperer les utilisateurs ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Impossible de recuperer les utilisateurs $e');
  }
}
