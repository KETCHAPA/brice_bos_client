import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/services/categoryService.dart';
import 'package:sweetalert/sweetalert.dart';

class AllCategoryPage extends StatefulWidget {
  @override
  _AllCategoryPageState createState() => _AllCategoryPageState();
}

class _AllCategoryPageState extends State<AllCategoryPage> {
  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  List<Category> childrenCategories = [];
  String catName = '';
  bool isLoadingChildren = false;
  List parentCategories = [], allCategories;
  GlobalKey<RefreshIndicatorState> _refreshKey2;

  loadAllCategories() async {
    setState(() {
      isLoadingChildren = true;
    });
    await getParentCategories().then((value) {
      setState(() {
        childrenCategories = value;
        isLoadingChildren = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshKey2 = GlobalKey<RefreshIndicatorState>();
    loadAllCategories();
    catName = 'Toutes';
    parentCategories.add(Category(name: 'Toutes'));
  }

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

  _fetchData() async {
    List<Category> _parentCategories = await fetchParentCategories();
    await setParentCategories(_parentCategories);
  }

  Future<Null> _refreshData2() async {
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

  List reloadArray(_name) {
    List _return = parentCategories;
    int index = parentCategories.indexOf(
        parentCategories.firstWhere((element) => element.name == _name));
    for (var i = index++; i < parentCategories.length; i++) {
      _return.removeAt(index);
    }
    return _return;
  }

  hasChildren(item) {
    bool _return = false;
    for (var cat in allCategories) {
      print('id ${cat.catId}');
      if (item.id == cat.catId) {
        _return = true;
      }
    }
    return _return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => null,
            icon: Icon(
              YvanIcons.left_arrow_1,
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
                  YvanIcons.loupe,
                  size: size(context).height / 40.0,
                  color: Colors.black,
                ),
                onPressed: _searchRedirection)
          ],
        ),
        body: FutureBuilder(
          future: fetchAllCategories(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              allCategories = snapshot.data;
              return RefreshIndicator(
                key: _refreshKey2,
                onRefresh: () async {
                  await _refreshData2();
                },
                child: Column(
                  children: [
                    Container(
                      height: size(context).height * .06,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: parentCategories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                catName = parentCategories[index].name;
                                parentCategories =
                                    reloadArray(parentCategories[index].name);
                                childrenCategories =
                                    catName == '' || catName == 'Toutes'
                                        ? loadAllCategories()
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
                                  color: parentCategories.length - 1 == index
                                      ? Colors.black
                                      : Colors.transparent,
                                  border: Border.all(color: Colors.black87),
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 10)),
                              alignment: Alignment.center,
                              child: Text(
                                parentCategories[index].name,
                                style: TextStyle(
                                    color: parentCategories.length - 1 == index
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: size(context).height / 50,
                    ),
                    Expanded(
                      child: isLoadingChildren
                          ? Center(child: loader())
                          : childrenCategories == null ||
                                  childrenCategories.length == 0
                              ? Center(child: Text('Aucune sous categorie'))
                              : ListView.builder(
                                  itemCount: childrenCategories.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        hasChildren(childrenCategories[index])
                                            ? setState(() {
                                                catName =
                                                    childrenCategories[index]
                                                        .name;
                                                parentCategories.add(
                                                    childrenCategories[index]);
                                                _fetchCategoriesChildren(
                                                    childrenCategories[index]
                                                        .id);
                                              })
                                            : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RouterPage(
                                                            index: 1,
                                                            category:
                                                                childrenCategories[
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size(context).height /
                                                            50),
                                                child: CachedNetworkImage(
                                                  imageUrl: imagePath(
                                                      childrenCategories[index]
                                                          .photo),
                                                  placeholder: (context, url) =>
                                                      loader(),
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0.0,
                                              child: Container(
                                                width:
                                                    size(context).width / 3.0,
                                                child: Image.asset(
                                                    'img/category1.png',
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
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size(context).height /
                                                              50)),
                                            ),
                                            Positioned(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: size(context).width /
                                                        20),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    childrenCategories[index]
                                                        .name,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: size(context)
                                                                .height /
                                                            45.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: size(context).width /
                                                        20),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    'Voir >',
                                                    style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: size(context)
                                                                .height /
                                                            45.0,
                                                        fontWeight:
                                                            FontWeight.bold),
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
              );
            }
            return Center(child: loader());
          },
        ));
  }
}
