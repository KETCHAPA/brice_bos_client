import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/products/show.dart';
import 'package:new_bos_app/services/categoryService.dart';
import 'package:new_bos_app/services/productService.dart';
import 'package:new_bos_app/services/shopService.dart';
import 'package:sweetalert/sweetalert.dart';

class AllProductPage extends StatefulWidget {
  final Category category;
  final Shop shop;
  final List products;

  const AllProductPage({Key key, this.category, this.shop, this.products})
      : super(key: key);

  @override
  _AllProductPageState createState() => _AllProductPageState();
}

class _AllProductPageState extends State<AllProductPage> {
  Future products;
  bool bottom = true;
  List carts;
  String title;

  _fetchData() async {
    if (widget.category != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AllProductPage(
                category: widget.category,
              )));
    } else if (widget.shop != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AllProductPage(
                shop: widget.shop,
              )));
    } else {
      List<Product> _products = await fetchAllProduct();
      await setAllProducts(_products);
      Navigator.of(context).popAndPushNamed('products');
    }
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

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      title = widget.category.name;
      products = fetchCategoryProduct(widget.category.code);
      bottom = false;
    } else if (widget.shop != null) {
      title = widget.shop.name;
      products = fetchShopProducts(widget.shop.code);
      bottom = false;
    } else {
      title = 'Produits';
      products = getAllProducts();
      bottom = true;
    }

    if (widget.products != null) {
      bottom = false;
    }
  }

  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: widget.category == null &&
                      widget.shop == null &&
                      widget.products == null
                  ? () {}
                  : () => Navigator.pop(context),
            ),
            primary: false,
            automaticallyImplyLeading: false,
            title: Text(title,
                style: TextStyle(
                    fontSize: size(context).height / 30.0,
                    color: Colors.black)),
            actions: [
              IconButton(
                onPressed: _searchRedirection,
                icon: Icon(
                  YvanIcons.loupe,
                  color: Colors.black,
                ),
              ),
              IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.shopping_basket,
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
                  onPressed: () => Navigator.pushNamed(context, 'cart'))
            ],
          ),
          body: RefreshIndicator(
              onRefresh: () async {
                await _refreshData();
              },
              child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: widget.products == null
                      ? FutureBuilder(
                          future: products,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Center(
                                  child: Text(
                                    'Une erreur est survenue. Veuillez rafraichir la page',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              List _data = [];
                              if (bottom) {
                                for (var item in snapshot.data) {
                                  if (!_data.contains(item)) {
                                    _data.add(item);
                                  }
                                }
                              } else {
                                _data = snapshot.data;
                              }
                              return snapshot.data.isEmpty
                                  ? Center(child: Text('Aucun produit '))
                                  : View(
                                      products: _data,
                                      bottom: bottom,
                                      carts: carts);
                            }

                            return Center(
                              child: loader(),
                            );
                          },
                        )
                      : View(
                          products: widget.products,
                          bottom: bottom,
                          carts: carts,
                        )))),
    );
  }
}

class View extends StatefulWidget {
  View({@required this.products, @required this.bottom, @required this.carts});
  final List products, carts;
  final bool bottom;
  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<View> {
  List data;
  @override
  void initState() {
    super.initState();
    data = widget.products;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: size(context).width / 30.0),
        child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            staggeredTileBuilder: (int index) => new StaggeredTile.count(
                2,
                index % 2 == 0
                    ? size(context).height / 195.0
                    : index % 3 == 0
                        ? size(context).height / 220.0
                        : size(context).height / 250.0),
            mainAxisSpacing: size(context).height / 22.0,
            crossAxisSpacing: size(context).width / 30.0,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      if (favoriteDescriptions
                              .contains(data[index].description) &&
                          favoriteNames.contains(data[index].name)) {
                        favorites.remove(data[index]);
                        favoriteDescriptions.remove(data[index].description);
                        favoriteNames.remove(data[index].name);
                      } else {
                        favorites.add(data[index]);
                        favoriteNames.add(data[index].name);
                        favoriteDescriptions.add(data[index].description);
                      }
                      storeFavorite(favorites);
                    });
                  },
                  onTap: () {
                    if (!recents.contains(widget.products[index])) {
                      recents.add(widget.products[index]);
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowProduct(
                                  code: widget.products[index].code,
                                  urlImage: widget.products[index].photo,
                                )));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          height: index % 2 == 0
                              ? size(context).height / 2.3
                              : index % 3 == 0
                                  ? size(context).height / 2.7
                                  : size(context).height / 3.1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 60),
                                  child: CachedNetworkImage(
                                    imageUrl: imagePath(data[index].photo),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => loader(),
                                    errorWidget: (context, url, error) =>
                                        new Icon(Icons.error),
                                  )),
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size(context).height / 60),
                                    color: Colors.black38),
                              ),
                              Positioned(
                                  bottom: size(context).height / 50.0,
                                  left: size(context).height / 80.0,
                                  child: Text(
                                    data[index].shopName,
                                    style: TextStyle(
                                        fontSize: size(context).height / 70.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Positioned(
                                top: 0,
                                left: 0.0,
                                child: widget.products[index].newPrice == 0
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.all(
                                            size(context).height / 200.0),
                                        padding: EdgeInsets.all(
                                            size(context).height / 50.0),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: Text(
                                          '- ${discountPercent(data[index].oldPrice, data[index].newPrice)}%',
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                    margin: EdgeInsets.all(
                                        size(context).height / 100),
                                    padding: EdgeInsets.all(
                                        size(context).height / 100),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    child: Icon(
                                      favoriteDescriptions.contains(
                                                  data[index].description) &&
                                              favoriteNames
                                                  .contains(data[index].name)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favoriteDescriptions.contains(
                                                  data[index].description) &&
                                              favoriteNames
                                                  .contains(data[index].name)
                                          ? Colors.red.withOpacity(.9)
                                          : Colors.black54,
                                      size: size(context).height / 50,
                                    )),
                              )
                            ],
                          )),
                      Container(
                        width: size(context).width / 2,
                        child: Text(
                          data[index].name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: size(context).height / 50),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: size(context).width / 3.3,
                            child: Text(
                              '${data[index].oldPrice} XAF',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size(context).height / 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          data[index].newPrice == null ||
                                  data[index].newPrice == 0
                              ? Container()
                              : Container(
                                  width: size(context).width / 7,
                                  child: Text(
                                    '${data[index].newPrice} XAF',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.red,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: size(context).height / 75,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                        ],
                      ),
                    ],
                  ),
                ),
            itemCount: data.length));
  }
}
