import 'package:flutter/material.dart';
import 'package:new_bos_app/account/account.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/home/home.dart';
import 'package:new_bos_app/orders/cart.dart';
import 'package:new_bos_app/products/all.dart';

class RouterPage extends StatefulWidget {
  final int index;

  const RouterPage({Key key, this.index}) : super(key: key);

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
  }

  Future<bool> _onWillPop() async {
    bool returnValue;
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size(context).height / 100)),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    returnValue = false;
                  });
                },
                child: Text('Annuler', style: TextStyle(color: Colors.pink)),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    returnValue = true;
                  });
                },
                child: Text('Continuer', style: TextStyle(color: Colors.pink)),
              ),
            ],
            title: Text('Sortie'),
            content: Text('Vous allez quitter l\'application'),
          );
        });
    return returnValue;
  }

  List<Widget> pages = [
    HomePage(),
    AllProductPage(),
    CartPage(),
    AccountPage(),
  ];

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
                icon: Icon(Icons.home), title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), title: Text('Favoris')),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket), title: Text('Panier')),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: Text('Compte'))
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
