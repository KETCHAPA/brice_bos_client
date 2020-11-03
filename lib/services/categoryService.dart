import 'package:new_bos_app/common/ENDPOINT.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/products.dart';

Future<List<Product>> fetchCategoryProduct(String code) async {
  try {
    final response = await http.get('$endPoint/categories/$code/allProducts');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Product.fromJson(item)).toList();
    }
    throw Exception(
        'Erreur de recuperation des produits de la categorie specifiee ${response.statusCode}');
  } catch (e) {
    throw Exception(
        'Erreur de recuperation des produits de la categorie specifiee $e');
  }
}

Future<List<Category>> fetchParentCategories() async {
  try {
    final response = await http.get('$endPoint/parentCategory');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Category.fromJson(item)).toList();
    }
    return null;
  } catch (e) {
    throw Exception('Erreur de recuperation des categories $e');
  }
}

Future<List<Category>> fetchAllCategories() async {
  try {
    final response = await http.get('$endPoint/allCategories');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      Iterable items = res['data'];
      return items.map((item) => new Category.fromJson(item)).toList();
    }
    return null;
  } catch (e) {
    throw Exception('Erreur de recuperation des categories $e');
  }
}
