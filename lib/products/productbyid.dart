import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/products/show.dart';
import 'package:new_bos_app/services/shopService.dart';
import 'package:sweetalert/sweetalert.dart';

class ProductsByIdPage extends StatefulWidget {
  final int id;
  ProductsByIdPage(this.id);

  @override
  _ProductsByIdPageState createState() => _ProductsByIdPageState();
}

class _ProductsByIdPageState extends State<ProductsByIdPage> {
  List<Product> products = [];
  Shop shop;
  Future data;
  bool bottom = true;

  _fetchData() async {}

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
    data = fetchProductsByShopId(widget.id);
    bottom = false;
  }

  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: <Widget>[
            Container(
              width: 40.0,
              child: Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(YvanIcons.bag),
                    color: Colors.black.withOpacity(.7),
                    onPressed: () {
                      Navigator.pushNamed(context, '/carts');
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Colors.red, Colors.deepOrangeAccent]),
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      child: Center(
                          child: Text('$length',
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                    ),
                  )
                ],
              ),
            )
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    color: Colors.grey.withOpacity(.3)),
                child: TextFormField(
                  decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      fillColor: Colors.grey,
                      hintText: 'Recherche...',
                      border: InputBorder.none),
                ),
              ),
              InkWell(
                onTap: _searchRedirection,
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                ),
              )
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _refreshData();
          },
          child: FutureBuilder(
            future: data,
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
                shop = new Shop.fromJson(snapshot.data['shop']);
                for (var item in snapshot.data['products']) {
                  products.add(new Product.fromJson(item));
                }
                return ListView(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 20.0,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    top: 3.0,
                                    bottom: 3.0,
                                    right: 2.0),
                                child: Text(
                                  'Triage par defaut',
                                  style: TextStyle(fontSize: 10.0),
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Spacer(),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 10.0,
                                  ),
                                  Spacer(),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: <Widget>[
                                  Container(
                                    width: 13.0,
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(60.0)),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                          imagePath(shop.photo ??
                                              'shops/clothes_shop.jpg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Text(shop.name,
                                      style: TextStyle(fontSize: 6.0))
                                ],
                              ),
                              Spacer(),
                              Icon(
                                Icons.tune,
                                size: 18.0,
                                color: Colors.deepOrange,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, left: 3.0),
                                child: Text(
                                  'Filtre',
                                  style: TextStyle(
                                      color: Colors.deepOrange, fontSize: 13.0),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: products == null || products.isEmpty
                                ? Center(child: Text('Aucun produit'))
                                : View(
                                    products: products,
                                    bottom: bottom,
                                  ))
                      ],
                    ),
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}

class View extends StatefulWidget {
  View({@required this.products, @required this.bottom});
  final List<Product> products;
  final bool bottom;
  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<View> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: widget.bottom
            ? MediaQuery.of(context).size.height - 191.0
            : MediaQuery.of(context).size.height - 135.0,
        child: ListView.builder(
          itemCount: widget.products.length,
          itemBuilder: (BuildContext context, index) {
            List<Product> data = widget.products;
            return InkWell(
              onDoubleTap: () {
                setState(() {
                  if (favoriteDescriptions.contains(data[index].description) &&
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
                            )));
              },
              child: Container(
                  child: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, bottom: 20.0, left: 10.0),
                child: Row(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 90,
                          height: 120.0,
                          child: Image.network(
                            imagePath('${widget.products[index].photo}'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        widget.products[index].newPrice == 0
                            ? Container()
                            : Container(
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10.0))),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    '-${discountPercent(widget.products[index].oldPrice, widget.products[index].newPrice)}%',
                                    style: TextStyle(
                                        fontSize: 10.0, color: Colors.white),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  widget.products[index].name.length > 20
                                      ? '${widget.products[index].name.substring(0, 20)}...'
                                      : widget.products[index].name,
                                  style: TextStyle(
                                      color: Colors.pink, fontSize: 15.0),
                                ),
                                Spacer(),
                                Icon(
                                  YvanIcons.add_to_favorite,
                                  color: favoriteDescriptions.contains(
                                              data[index].description) &&
                                          favoriteNames
                                              .contains(data[index].name)
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 15.0,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  widget.products[index].newPrice == 0 ||
                                          widget.products[index].newPrice ==
                                              null
                                      ? '${widget.products[index].oldPrice} Fcfa'
                                      : '${widget.products[index].newPrice} Fcfa',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                Spacer(),
                                Text(
                                  widget.products[index].newPrice == 0
                                      ? ''
                                      : '${widget.products[index].oldPrice} Fcfa',
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: <Widget>[
                                renderStars(widget.products[index].rate),
                                Spacer(),
                                Text(
                                    'Disponible: ${widget.products[index].available}')
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  widget.products[index].shopName.length > 16
                                      ? 'Boutique: ${widget.products[index].shopName.substring(0, 16)}...'
                                      : 'Boutique: ${widget.products[index].shopName}',
                                  style: TextStyle(fontSize: 13.0),
                                ),
                                Spacer(),
                                Icon(Icons.more_vert)
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
            );
          },
        ),
      ),
    );
  }
}
