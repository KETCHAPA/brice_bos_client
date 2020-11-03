import 'package:flutter/material.dart';
import 'package:new_bos_app/auth/choice.dart';
import 'package:new_bos_app/categories/all.dart';
import 'package:new_bos_app/favorites/product.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/splash/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buy, On Send',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(
            elevation: 0,
            color: Colors.white,
          )),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        'home': (context) => RouterPage(),
        'choice': (context) => ChoicePage(),
        'products': (context) => RouterPage(
              index: 1,
            ),
        'categories': (context) => AllCategoryPage(),
        'cart': (context) => RouterPage(
              index: 2,
            ),
        'favorites': (context) => FavoriteProducts(),
        'account': (context) => RouterPage(
              index: 3,
            ),
      },
    );
  }
}
