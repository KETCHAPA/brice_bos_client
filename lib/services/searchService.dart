import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/common/removeAccent.dart';
import 'package:new_bos_app/model/data.dart';
import 'package:new_bos_app/products/all.dart';
import 'package:new_bos_app/products/show.dart';

Future<List<Data>> search(String query) async {
  try {
    var _categories = await getAllCategories();
    var _products = await getAllProducts();
    var _shops = await getShops();

    List<Data> _datas = [];

    for (var item in _shops) {
      if (removeDiacritics(item.name)
              .toLowerCase()
              .contains(removeDiacritics(query).toLowerCase()) ||
          removeDiacritics(item.description)
              .toLowerCase()
              .contains(removeDiacritics(query).toLowerCase())) {
        _datas.add(Data(
            title: item.name,
            description: item.description,
            parent: 'Boutiques',
            photo: item.photo,
            redirection: AllProductPage(
              shop: item,
            )));
      }
    }

    for (var item in _categories) {
      if (removeDiacritics(item.name)
              .toLowerCase()
              .contains(removeDiacritics(query).toLowerCase()) ||
          removeDiacritics(item.description)
              .toLowerCase()
              .contains(removeDiacritics(query).toLowerCase())) {
        _datas.add(Data(
            title: item.name,
            description: item.description,
            parent: 'Categories',
            photo: item.photo,
            redirection: AllProductPage(
              category: item,
            )));
      }
    }

    for (var item in _products) {
      if (removeDiacritics(item.name)
              .toLowerCase()
              .contains(removeDiacritics(query).toLowerCase()) ||
          removeDiacritics(item.description)
              .toLowerCase()
              .contains(removeDiacritics(query).toLowerCase()) ||
          item.oldPrice == query ||
          item.newPrice == query) {
        _datas.add(Data(
            title: item.name,
            description: item.description,
            parent: 'Produits',
            oldPrice: item.oldPrice,
            newPrice: item.newPrice,
            details: item.shopName,
            photo: item.photo,
            redirection: ShowProduct(/* code: item.code */)));
      }
    }

    return _datas;
  } catch (e) {
    throw Error();
  }
}
