import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/products/all.dart';
import 'package:new_bos_app/services/categoryService.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:http/http.dart' as http;

class AllCategoryPage extends StatefulWidget {
  @override
  _AllCategoryPageState createState() => _AllCategoryPageState();
}

class _AllCategoryPageState extends State<AllCategoryPage> {
  List<Category> recommandationData = [
        Category(name: 'Chaussures', photo: 'main_category_photos/baskets.jpg'),
        Category(name: 'Pantalons', photo: 'main_category_photos/pants.jpg'),
        Category(name: 'Robes', photo: 'main_category_photos/women.jpg'),
        Category(name: 'Chemises', photo: 'main_category_photos/clothes.jpg'),
        Category(name: 'Jupes', photo: 'main_category_photos/child.jpg'),
        Category(
            name: 'Boucles d\'oreille',
            photo: 'main_category_photos/watches.jpg'),
        Category(name: 'Enfants', photo: 'main_category_photos/child.jpg'),
        Category(name: 'Femmes', photo: 'main_category_photos/women.jpg')
      ],
      childrenCategories;
  String catName = '';
  int isSelected = 0;
  List<String> bannerImages = [];
  int _currentPage = 0;
  PageController _pageController = PageController();
  bool isLoadingChildren = false;
  Future _parentCategories;
  GlobalKey<RefreshIndicatorState> _refreshKey;

  _fetchCategoriesChildren(id) async {
    setState(() {
      isLoadingChildren = true;
    });
    try {
      final response = await http.get('$endPoint/childrenCategory/$id');
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        Iterable items = res['data'];
        childrenCategories.clear();
        items
            .map((item) => childrenCategories.add(new Category.fromJson(item)))
            .toList();
        setState(() {
          isLoadingChildren = false;
        });
      }
    } catch (e) {
      throw Exception('Erreur de recuperation des categories $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    childrenCategories = recommandationData;
    _parentCategories = getParentCategories();

    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (bannerImages != null) {
        if (_currentPage < bannerImages.length) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
      }

      _pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 350), curve: Curves.bounceOut);
    });
  }

  _fetchData() async {
    List<Category> _parentCategories = await fetchParentCategories();
    await setParentCategories(_parentCategories);
  }

  Future<Null> _refreshData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await _fetchData();
    } else {
      new Future.delayed(Duration(seconds: 3), () {
        sweetalert(
          context: context,
          withConfirmation: false,
          title: 'Pas de connexion',
          subtitle:
              '  Pour une meilleure experience,\nactivez votre connexion internet.',
          type: SweetAlertStyle.confirm,
        );
      });
      return null;
    }
  }

  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Categories',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: _searchRedirection)
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          await _refreshData();
          Navigator.of(context).popAndPushNamed('/categories');
        },
        child: Column(
          children: [
            FutureBuilder(
                future: _parentCategories,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Center(
                        child: Text(
                          'Une erreur est survenue. Veuillez rafraichir la page',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    List parentCategories = [];
                    parentCategories.add(Category(name: 'Recommandations'));
                    for (var item in snapshot.data) {
                      if (!parentCategories.contains(item)) {
                        parentCategories.add(item);
                      }
                    }
                    return Container(
                      height: size(context).height * .05,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: parentCategories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isSelected = index;
                                catName = parentCategories[index].name;
                                childrenCategories =
                                    catName == 'Recommandations' ||
                                            catName == ''
                                        ? recommandationData
                                        : _fetchCategoriesChildren(
                                            parentCategories[index].id);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size(context).width / 20,
                                  vertical: size(context).width / 100),
                              margin: EdgeInsets.only(
                                  left: size(context).width / 20,
                                  right: index == 9
                                      ? size(context).width / 20
                                      : 0.0),
                              decoration: BoxDecoration(
                                  color: isSelected == index
                                      ? Colors.black
                                      : Colors.transparent,
                                  border: Border.all(color: Colors.black87),
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 10)),
                              alignment: Alignment.center,
                              child: Text(
                                parentCategories[index].name,
                                style: TextStyle(
                                    color: isSelected == index
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Container();
                }),
            SizedBox(
              height: size(context).height / 50,
            ),
            Expanded(
              child: isLoadingChildren
                  ? Center(child: loader())
                  : childrenCategories == null || childrenCategories.length == 0
                      ? Center(child: Text('Aucune sous categorie'))
                      : ListView.builder(
                          itemCount: childrenCategories.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => catName ==
                                                    'Recommandations' ||
                                                catName == ''
                                            ? RouterPage(index: 1)
                                            : AllProductPage(
                                                category: childrenCategories[
                                                    index])));
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    size(context).width / 20,
                                    index == 0
                                        ? size(context).height / 100
                                        : 0.0,
                                    size(context).width / 20,
                                    size(context).height / 50),
                                height: size(context).height / 6,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(
                                        size(context).height / 50)),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size(context).height / 50),
                                        child: CachedNetworkImage(
                                          imageUrl: imagePath(
                                              childrenCategories[index].photo),
                                          placeholder: (context, url) =>
                                              loader(),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0.0,
                                      child: Container(
                                        width: size(context).width / 3.0,
                                        child: Image.asset('img/category1.png',
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.black45,
                                                Colors.black45,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter),
                                          borderRadius: BorderRadius.circular(
                                              size(context).height / 50)),
                                    ),
                                    Positioned(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: size(context).width / 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            childrenCategories[index].name,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    size(context).height / 45.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: size(context).width / 20),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Voir >',
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontSize:
                                                    size(context).height / 45.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
            ),
          ],
        ),
      ),
    );
  }
}
