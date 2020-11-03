import 'package:new_bos_app/common/ENDPOINT.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/model/products.dart';

Future<List<Product>> fetchAllProduct() async {
  try {
    final response = await http.get('$endPoint/products');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Product.fromJson(item)).toList();
    }

    print(response.statusCode);
    throw Exception('Erreur de recuperation des produit');
  } catch (e) {
    throw Exception('Erreur de recuperation des produits');
  }
}

Future<Map<String, dynamic>> fetchProduct(String code) async {
  try {
    final response = await http.get('$endPoint/product/$code/show');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      return res['data'];
    }
    print(response.statusCode);
    throw Exception('Echec de recuperation du produit $code');
  } catch (e) {
    throw Exception('Echec de recuperation du produit $e');
  }
}

Future fetchAllReviews(String code) async {
  try {
    final response = await http.get('$endPoint/reviews/$code');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items;
    }
    print(response.statusCode);
  } catch (e) {
    throw Exception('Erreur de recuperation des Avis des clients');
  }
}
