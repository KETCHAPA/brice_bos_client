import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/categories/all.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/home/counter.dart';
import 'package:new_bos_app/home/shopview.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/model/promotions.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/products/all.dart';
import 'package:new_bos_app/products/productbyid.dart';
import 'package:new_bos_app/products/show.dart';
import 'package:new_bos_app/services/homeService.dart';
import 'package:sweetalert/sweetalert.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          await _refreshData();
          Navigator.of(context).popAndPushNamed('home');
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
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllCategoryPage())),
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
                                                          AllProductPage(
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
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AllCategoryPage()))
                                                  : Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AllProductPage(
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
                                                    AllProductPage(
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
                                                            AllProductPage(
                                                              products:
                                                                  _flashSalesData,
                                                            )))
                                                : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ShowProduct(
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
                                                    AllProductPage(
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
                                                        ShowProduct(
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
}

List<String> defaultBanners = ['start1.jpg', 'start2.jpg'];
