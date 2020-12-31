import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/model/promotions.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/services/categoryService.dart';
import 'package:new_bos_app/services/homeService.dart';
import 'package:new_bos_app/services/productService.dart';
import 'package:sweetalert/sweetalert.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void navigationBar() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      List<Shop> _shops = await fetchShops();
      List<Product> _products = await fetchAllProduct();
      List<Category> _mainCategories = await fetchMainCategory();
      List<Category> _allCategories = await fetchAllCategories();
      List<Product> _dailyDeals = await fetchDailyDeals();
      List<Product> _flashSales = await fetchFlashSales();
      List<Promotion> _banners = await fetchBanners();
      List<Category> _parentCategories = await fetchParentCategories();

      await setFlashSales(_flashSales);
      await setMainCategories(_mainCategories);
      await setShops(_shops);
      await setAllCategories(_allCategories);
      await setDailyDeals(_dailyDeals);
      await setBanners(_banners);
      await setAllProducts(_products);
      await setParentCategories(_parentCategories);

      myFirstConnexion = await isFirstConnexion();

      if (myFirstConnexion) {
        await setFirstConnexion();
        Navigator.pushNamed(context, 'choice');
      } else {
        isLoggedIn = await isLogged();
        if (isLoggedIn) {
          Map _user = await getCurrentUser();
          token = await getUserToken();
          userCode = _user['code'];
          userId = _user['id'];
        }
        Navigator.pushNamed(context, 'home');
      }
    } else {
      new Future.delayed(Duration(seconds: 3), () {
        sweetalert(
          context: context,
          withConfirmation: false,
          title: 'Pas de connexion',
          subtitle:
              'Pour votre premiere connexion, veuillez\n         activez votre connexion internet.',
          type: SweetAlertStyle.confirm,
        );
      });
      Navigator.pushNamed(context, 'splash');
    }
  }

  _fillData() async {
    length = await getCartLength();
    total = await getCartTotal();
    quantities = await getCartQuantities();
    carts = (await getCart()).map((cart) => Product.fromJson(cart)).toList();
    favorites =
        (await getFavorite()).map((cart) => Product.fromJson(cart)).toList();
    favoritesShops =
        (await getFavoriteShops()).map((shop) => Shop.fromJson(shop)).toList();

    for (var item in carts) {
      cartDescription.add(item.description);
      cartNames.add(item.name);
      commandShopIds.add(item.shopId);
      shopNames.add(item.shopName);
    }
    for (var item in favorites) {
      favoriteDescriptions.add(item.description);
      favoriteNames.add(item.name);
    }
    for (var item in favoritesShops) {
      favoriteShopNames.add(item.name);
    }

    setNumberOfShopInCommand();
  }

  startTime() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light));
    Duration _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationBar);
  }

  @override
  void initState() {
    super.initState();
    startTime();
    _fillData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('img/start1.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black38, Colors.black54, Colors.black87])),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'title',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BUY, ON SEND',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: size(context).height / 25,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Bienvenue,',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: size(context).height / 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              loader()
            ],
          )
        ],
      ),
    );
  }
}
