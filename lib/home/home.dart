//Subpage product
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'dart:convert';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/home/counter.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/home/shopview.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/model/promotions.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/products/productbyid.dart';
import 'package:new_bos_app/services/categoryService.dart';
import 'package:new_bos_app/services/homeService.dart';
import 'package:sweetalert/sweetalert.dart';

class FirstIconRouter extends StatefulWidget {
  @override
  _FirstIconRouterState createState() => _FirstIconRouterState();
}

class _FirstIconRouterState extends State<FirstIconRouter> {
  bool isHomePage;
  Future _mainCategories, _flashSales, _shops, _dailyDeals;
  int _currentPage = 0;
  PageController _pageController = PageController();
  List<String> bannerImages = [];
  List<int> bannerRedirection = [];
  double maxDiscount;
  bool firstEntry = true;
  GlobalKey<RefreshIndicatorState> _refreshKey;
  bool emptyBanners;
  List _shopsData;
  List<Category> childrenCategories = [];
  String catName = '';
  bool isLoadingChildren = false;
  List parentCategories = [], allCategories;
  GlobalKey<RefreshIndicatorState> _refreshKey2;

  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

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

  _fetchDataFromServer() async {
    List<Shop> _shop1 = await fetchShops();
    List<Category> _mainCategorie1 = await fetchMainCategory();
    List<Product> _dailyDeal1 = await fetchDailyDeals();
    List<Product> _flashSale1 = await fetchFlashSales();
    List<Promotion> _banner1 = await fetchBanners();

    await setFlashSales(_flashSale1);
    await setMainCategories(_mainCategorie1);
    await setShops(_shop1);
    await setDailyDeals(_dailyDeal1);
    await setBanners(_banner1);
  }

  Future<Null> _refreshData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await _fetchDataFromServer();
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

  int isSelected = 0;

  @override
  void initState() {
    super.initState();
    isHomePage = true;
    emptyBanners = false;
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    _mainCategories = getMainCategories();
    _flashSales = getFlashSales();
    _shops = getShops();
    _dailyDeals = getDailyDeals();

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
    _refreshKey2 = GlobalKey<RefreshIndicatorState>();
    loadAllCategories();
    catName = 'Toutes';
    parentCategories.add(Category(name: 'Toutes'));
  }

  Widget firstWidget() {
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          await _refreshData();
          setState(() {
            isHomePage = true;
          });
        },
        child: SafeArea(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    YvanIcons.left_arrow_1,
                    color: Colors.transparent,
                  ),
                ),
                flexibleSpace: FutureBuilder(
                    future: getBanners(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        for (var item in snapshot.data) {
                          if (!bannerImages.contains(item.photo)) {
                            bannerImages.add(item.photo);
                            bannerRedirection.add(item.shopId);
                          }
                        }
                        if (bannerImages.isEmpty) {
                          for (var item in defaultBanners) {
                            if (!bannerImages.contains(item)) {
                              emptyBanners = true;
                              bannerImages.add(item);
                            }
                          }
                        }
                        return emptyBanners
                            ? Stack(
                                children: <Widget>[
                                  PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (val) {
                                      setState(() {
                                        _currentPage = val;
                                      });
                                    },
                                    itemCount: bannerImages.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return Image.asset(
                                          'img/${bannerImages[index]}',
                                          fit: BoxFit.cover);
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 12.0 * bannerImages.length,
                                      height: 20.0,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: bannerImages.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.brightness_1,
                                                size: index == _currentPage
                                                    ? 7.2
                                                    : 7.0,
                                                color: index == _currentPage
                                                    ? Color(0xff31275c)
                                                    : Colors.blueGrey
                                                        .withOpacity(.3),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                          Colors.white10,
                                          Colors.white30,
                                          Colors.white,
                                        ])),
                                  ),
                                ],
                              )
                            : Stack(
                                children: <Widget>[
                                  PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (val) {
                                      setState(() {
                                        _currentPage = val;
                                      });
                                    },
                                    itemCount: bannerImages.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductsByIdPage(
                                                          bannerRedirection[
                                                              index])));
                                        },
                                        child: Image.network(
                                            imagePath(bannerImages[index]),
                                            fit: BoxFit.cover),
                                      );
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 12.0 * bannerImages.length,
                                      height: 20.0,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: bannerImages.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.brightness_1,
                                                size: index == _currentPage
                                                    ? 7.2
                                                    : 7.0,
                                                color: index == _currentPage
                                                    ? Color(0xff31275c)
                                                    : Colors.blueGrey
                                                        .withOpacity(.3),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                          Colors.white10,
                                          Colors.white30,
                                          Colors.white,
                                        ])),
                                  ),
                                ],
                              );
                      }
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
                      return loader();
                    }),
                expandedHeight: size(context).height / 2.2,
                floating: false,
                pinned: false,
                primary: false,
                actions: [
                  IconButton(
                    onPressed: _searchRedirection,
                    icon: Icon(
                      YvanIcons.loupe,
                      size: size(context).height / 40.0,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, 'favorites'),
                    icon: Icon(
                      YvanIcons.add_to_favorite,
                      size: size(context).height / 40.0,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, 'cart'),
                    icon: Stack(
                      children: [
                        Icon(
                          YvanIcons.bag,
                          color: Colors.black,
                        ),
                        Positioned(
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            padding: EdgeInsets.all(size(context).height / 200),
                            child: Text(
                              length.toString(),
                              style: TextStyle(
                                  fontSize: size(context).height / 70.0,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size(context).width / 30.0,
                      vertical: size(context).height / 100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size(context).height / 40.0),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          isHomePage = false;
                        }),
                        child: Icon(
                          YvanIcons.arrow_drop_right_line,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                  future: _mainCategories,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      List<Category> _mainCategoriesData = [];
                      for (var item in snapshot.data) {
                        if (!_mainCategoriesData.contains(item)) {
                          _mainCategoriesData.add(item);
                        }
                      }
                      return _mainCategoriesData.isEmpty
                          ? SizedBox(
                              height: 0.0,
                            )
                          : Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20.0,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 68.0,
                                      child: ListView.builder(
                                        itemExtent:
                                            MediaQuery.of(context).size.width *
                                                .24,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            _mainCategoriesData.length > 4
                                                ? 4
                                                : _mainCategoriesData.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RouterPage(
                                                            index: 1,
                                                            category:
                                                                _mainCategoriesData[
                                                                    index],
                                                          )));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(children: <Widget>[
                                                Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  60.0)),
                                                    ),
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: imagePath(
                                                            _mainCategoriesData[
                                                                    index]
                                                                .photo),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                loader(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    )),
                                                Text(
                                                  _mainCategoriesData[index]
                                                              .name
                                                              .length >
                                                          13
                                                      ? '${_mainCategoriesData[index].name.substring(0, 13)}...'
                                                      : _mainCategoriesData[
                                                              index]
                                                          .name,
                                                  style:
                                                      TextStyle(fontSize: 11.0),
                                                )
                                              ]),
                                            ),
                                          );
                                        },
                                      )),
                                ),
                              ],
                            );
                    }
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

                    return loader();
                  },
                ),
                FutureBuilder(
                  future: _mainCategories,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      List<Category> _mainCategoriesData = [];
                      for (var item in snapshot.data) {
                        if (!_mainCategoriesData.contains(item)) {
                          _mainCategoriesData.add(item);
                        }
                      }
                      _mainCategoriesData.add(Category(
                          name: 'Voir plus',
                          photo: 'main_category_photos/plus.png'));
                      return _mainCategoriesData.isEmpty
                          ? SizedBox(
                              height: 0.0,
                            )
                          : Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20.0,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 68.0,
                                      child: ListView.builder(
                                        itemExtent:
                                            MediaQuery.of(context).size.width *
                                                .24,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 4,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              _mainCategoriesData[index + 4]
                                                          .photo ==
                                                      'main_category_photos/plus.png'
                                                  ? setState(() {
                                                      isHomePage = false;
                                                    })
                                                  : Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              RouterPage(
                                                                index: 1,
                                                                category:
                                                                    _mainCategoriesData[
                                                                        index],
                                                              )));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(children: <Widget>[
                                                Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      border: _mainCategoriesData[
                                                                      index + 4]
                                                                  .photo ==
                                                              'main_category_photos/plus.png'
                                                          ? null
                                                          : Border.all(
                                                              color:
                                                                  Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  60.0)),
                                                    ),
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: imagePath(
                                                            _mainCategoriesData[
                                                                    index + 4]
                                                                .photo),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                loader(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    )),
                                                Text(
                                                  _mainCategoriesData[index + 4]
                                                              .name
                                                              .length >
                                                          13
                                                      ? '${_mainCategoriesData[index + 4].name.substring(0, 13)}...'
                                                      : _mainCategoriesData[
                                                              index + 4]
                                                          .name,
                                                  style:
                                                      TextStyle(fontSize: 11.0),
                                                )
                                              ]),
                                            ),
                                          );
                                        },
                                      )),
                                ),
                              ],
                            );
                    }
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

                    return Container();
                  },
                ),
                FutureBuilder(
                  future: _shops,
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
                      if (_shopsData == null) {
                        _shopsData = [];
                        for (var item in snapshot.data) {
                          if (!_shopsData.contains(item)) {
                            _shopsData.add(item);
                          }
                        }
                      }
                      return ShopView(_shopsData);
                    }

                    return loader();
                  },
                ),
                FutureBuilder(
                  future: _flashSales,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      List _flashSalesData = [];
                      for (var item in snapshot.data) {
                        if (!_flashSalesData.contains(item)) {
                          _flashSalesData.add(item);
                        }
                      }
                      return _flashSalesData.length == 0
                          ? SizedBox(
                              height: 0.0,
                            )
                          : Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size(context).width / 30.0,
                                      vertical: size(context).height / 50.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ventes Flash',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                size(context).height / 40.0),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RouterPage(
                                                      index: 1,
                                                      products: _flashSalesData,
                                                    ))),
                                        child: Row(
                                          children: [
                                            Counter(),
                                            Icon(
                                              YvanIcons.arrow_drop_right_line,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: size(context).height / 4,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _flashSalesData.length > 5
                                          ? 5
                                          : _flashSalesData.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            if (!(_flashSalesData[index]
                                                        .newPrice ==
                                                    -1) &&
                                                !recents.contains(
                                                    _flashSalesData[index])) {
                                              recents
                                                  .add(_flashSalesData[index]);
                                            }
                                            _flashSalesData[index].newPrice ==
                                                    -1
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RouterPage(
                                                              index: 1,
                                                              products:
                                                                  _flashSalesData,
                                                            )))
                                                : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RouterPage(
                                                              index: 1,
                                                              showDetails: true,
                                                              code:
                                                                  _flashSalesData[
                                                                          index]
                                                                      .code,
                                                            )));
                                          },
                                          onDoubleTap: () {
                                            setState(() {
                                              if (favoriteDescriptions.contains(
                                                      _flashSalesData[index]
                                                          .description) &&
                                                  favoriteNames.contains(
                                                      _flashSalesData[index]
                                                          .name)) {
                                                favorites.remove(
                                                    _flashSalesData[index]);
                                                favoriteDescriptions.remove(
                                                    _flashSalesData[index]
                                                        .description);
                                                favoriteNames.remove(
                                                    _flashSalesData[index]
                                                        .name);
                                              } else {
                                                favorites.add(
                                                    _flashSalesData[index]);
                                                favoriteNames.add(
                                                    _flashSalesData[index]
                                                        .name);
                                                favoriteDescriptions.add(
                                                    _flashSalesData[index]
                                                        .description);
                                              }
                                              storeFavorite(favorites);
                                            });
                                          },
                                          child: Container(
                                            width: size(context).width / 3,
                                            margin: EdgeInsets.only(
                                                left: index == 0
                                                    ? size(context).width / 30.0
                                                    : 0,
                                                right:
                                                    size(context).width / 30.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size(context)
                                                                    .height /
                                                                100.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: imagePath(
                                                          '${_flashSalesData[index].photo}'),
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              loader(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size(context)
                                                                    .height /
                                                                100.0),
                                                    color: Colors.black38,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0.0,
                                                  child: Container(
                                                    margin: EdgeInsets.all(
                                                        size(context).height /
                                                            100.0),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          size(context).height /
                                                              100.0,
                                                      vertical:
                                                          size(context).height /
                                                              200.0,
                                                    ),
                                                    alignment: Alignment.center,
                                                    height:
                                                        size(context).height /
                                                            20.0,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size(context)
                                                                      .height /
                                                                  100.0),
                                                    ),
                                                    child: Text(
                                                      'XAF ${_flashSalesData[index].newPrice}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              size(context)
                                                                      .height /
                                                                  60.0),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0.0,
                                                  right: 0.0,
                                                  child: Container(
                                                    margin: EdgeInsets.all(
                                                        size(context).height /
                                                            100.0),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size(context)
                                                                      .height /
                                                                  100.0),
                                                    ),
                                                    child: Text(
                                                      '-${discountPercent(_flashSalesData[index].oldPrice, _flashSalesData[index].newPrice)} %',
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              size(context)
                                                                      .height /
                                                                  40.0),
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
                            );
                    }
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

                    return loader();
                  },
                ),
                FutureBuilder(
                  future: _dailyDeals,
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
                      List _dailyDealsData = [];
                      for (var item in snapshot.data) {
                        if (!_dailyDealsData.contains(item)) {
                          _dailyDealsData.add(item);
                        }
                      }
                      return _dailyDealsData.isEmpty
                          ? SizedBox(
                              height: 0.0,
                            )
                          : Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size(context).width / 30.0,
                                      vertical: size(context).height / 100.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Offres du jour',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                size(context).height / 40.0),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RouterPage(
                                                      index: 1,
                                                      products: _dailyDealsData,
                                                    ))),
                                        child: Icon(
                                          YvanIcons.arrow_drop_right_line,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: size(context).height / 4,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _dailyDealsData.length > 5
                                          ? 5
                                          : _dailyDealsData.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            if (!recents.contains(
                                                _dailyDealsData[index])) {
                                              recents
                                                  .add(_dailyDealsData[index]);
                                            }
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RouterPage(
                                                          index: 1,
                                                          showDetails: true,
                                                          code: _dailyDealsData[
                                                                  index]
                                                              .code,
                                                        )));
                                          },
                                          onDoubleTap: () {
                                            setState(() {
                                              if (favoriteDescriptions.contains(
                                                      _dailyDealsData[index]
                                                          .description) &&
                                                  favoriteNames.contains(
                                                      _dailyDealsData[index]
                                                          .name)) {
                                                favorites.remove(
                                                    _dailyDealsData[index]);
                                                favoriteDescriptions.remove(
                                                    _dailyDealsData[index]
                                                        .description);
                                                favoriteNames.remove(
                                                    _dailyDealsData[index]
                                                        .name);
                                              } else {
                                                favorites.add(
                                                    _dailyDealsData[index]);
                                                favoriteNames.add(
                                                    _dailyDealsData[index]
                                                        .name);
                                                favoriteDescriptions.add(
                                                    _dailyDealsData[index]
                                                        .description);
                                              }
                                              storeFavorite(favorites);
                                            });
                                          },
                                          child: Container(
                                            width: size(context).width / 3,
                                            margin: EdgeInsets.only(
                                                left: index == 0
                                                    ? size(context).width / 30.0
                                                    : 0,
                                                right:
                                                    size(context).width / 30.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size(context)
                                                                    .height /
                                                                100.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: imagePath(
                                                          _dailyDealsData[index]
                                                              .photo),
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              loader(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size(context)
                                                                    .height /
                                                                100.0),
                                                    color: Colors.black38,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0.0,
                                                  right: 0.0,
                                                  left: 0.0,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: size(
                                                                        context)
                                                                    .height /
                                                                100.0,
                                                            vertical: size(
                                                                        context)
                                                                    .height /
                                                                200.0),
                                                    alignment: Alignment.center,
                                                    height:
                                                        size(context).height /
                                                            20.0,
                                                    child: Text(
                                                      '${discountPercent(_dailyDealsData[index].oldPrice, _dailyDealsData[index].newPrice)}% Off',
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.orange,
                                                          fontSize:
                                                              size(context)
                                                                      .height /
                                                                  40.0),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0.0,
                                                  right: 0.0,
                                                  left: 0.0,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: size(
                                                                        context)
                                                                    .height /
                                                                100.0,
                                                            vertical: size(
                                                                        context)
                                                                    .height /
                                                                200.0),
                                                    alignment: Alignment.center,
                                                    height:
                                                        size(context).height /
                                                            20.0,
                                                    child: Text(
                                                      'XAF ${_dailyDealsData[index].newPrice}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize:
                                                              size(context)
                                                                      .height /
                                                                  55.0),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            );
                    }
                    return loader();
                  },
                ),
                SizedBox(
                  height: size(context).height / 50.0,
                )
              ]))
            ],
          ),
        ),
      ),
    );
  }

  Widget secondWidget() {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => setState(() {
              isHomePage = true;
            }),
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

  @override
  Widget build(BuildContext context) {
    print(isHomePage);
    return isHomePage ? firstWidget() : secondWidget();
  }
}

List<String> defaultBanners = ['start1.jpg', 'start2.jpg'];
