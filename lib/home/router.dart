import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_bos_app/account/account.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/favorites/product.dart';
import 'package:new_bos_app/favorites/shop.dart';
import 'package:new_bos_app/home/home.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/orders/cart.dart';
import 'package:new_bos_app/products/all.dart';

class RouterPage extends StatefulWidget {
  final int index;
  final bool isProduct;
  final Category category;
  final Shop shop;
  final String code;
  final bool canPopFavorite;
  final bool showDetails;
  final List products;

  const RouterPage(
      {Key key,
      this.index,
      this.code,
      this.showDetails,
      this.isProduct = false,
      this.canPopFavorite,
      this.category,
      this.shop,
      this.products})
      : super(key: key);

  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  int currentIndex;
  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      currentIndex = widget.index;
    } else {
      currentIndex = 0;
    }
    pages = [
      FirstIconRouter(),
      widget.category != null
          ? AllProductPage(
              showDetails: widget.showDetails ?? false,
              productCode: widget.code,
              category: widget.category,
            )
          : widget.products != null
              ? AllProductPage(
                  showDetails: widget.showDetails ?? false,
                  productCode: widget.code,
                  products: widget.products,
                )
              : widget.shop != null
                  ? AllProductPage(
                      showDetails: widget.showDetails ?? false,
                      productCode: widget.code,
                      shop: widget.shop,
                    )
                  : AllProductPage(
                      showDetails: widget.showDetails ?? false,
                      productCode: widget.code,
                    ),
      widget.isProduct
          ? FavoriteProducts(
              canPop: widget.canPopFavorite,
            )
          : FavoriteShops(
              canPop: widget.canPopFavorite,
            ),
      CartPage(),
      AccountPage(),
    ];
  }

  Future<bool> _onWillPop() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(size(context).height / 100)),
            actions: <Widget>[
              FlatButton(
                onPressed: () async => SystemNavigator.pop(),
                child: Text('Continuer', style: TextStyle(color: Colors.pink)),
              ),
              FlatButton(
                onPressed: () async => Navigator.pop(context),
                child: Text('Annuler', style: TextStyle(color: Colors.pink)),
              ),
            ],
            title: Text('Sortie'),
            content: Text('Vous allez quitter l\'application'),
          );
        });
  }

  List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          selectedIconTheme: IconThemeData(size: size(context).height / 30.0),
          unselectedIconTheme: IconThemeData(size: size(context).height / 30.0),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(
                icon: Icon(YvanIcons.home_line), title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(YvanIcons.coupon), title: Text('Favoris')),
            BottomNavigationBarItem(
                icon: Icon(YvanIcons.heart), title: Text('Boutiques')),
            BottomNavigationBarItem(
                icon: Icon(YvanIcons.bag), title: Text('Panier')),
            BottomNavigationBarItem(
                icon: Icon(YvanIcons.user_6_line), title: Text('Compte'))
          ]),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: PageView(
          onPageChanged: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          pageSnapping: true,
          children: [pages[currentIndex]],
        ),
      ),
    );
  }
}
