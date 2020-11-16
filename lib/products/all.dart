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
import 'package:new_bos_app/services/appService.dart';
import 'package:new_bos_app/services/categoryService.dart';
import 'package:new_bos_app/services/productService.dart';
import 'package:new_bos_app/services/shopService.dart';
import 'package:sweetalert/sweetalert.dart';

class AllProductPage extends StatefulWidget {
  final Category category;
  final Shop shop;
  final String productCode;
  final List products;
  final bool showDetails;

  const AllProductPage(
      {Key key,
      this.showDetails,
      this.productCode,
      this.category,
      this.shop,
      this.products})
      : super(key: key);

  @override
  _AllProductPageState createState() => _AllProductPageState();
}

bool showDetailsProduct;
String productCode;

class _AllProductPageState extends State<AllProductPage> {
  Future products;
  bool bottom = true;
  String title;
  Future<Map> productSpecs;
  Product product;
  List categoryMap = [], pics = [];
  int nbrPics = 0;
  Future _reviews;

  String format(String date) {
    DateTime data = DateTime.parse(date);
    return '${data.day} ${months[data.month - 1]} ${data.year}';
  }

  int _selectedItem = 0;
  Widget _pageSelectedIndex(int length) {
    return Container(
      height: 20.0,
      width: length * 9.0,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: ScrollPhysics(parent: null),
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          return Icon(
            Icons.brightness_1,
            size: 7.0,
            color: index == _selectedItem ? Colors.black : Colors.blueGrey,
          );
        },
      ),
    );
  }

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
    showDetailsProduct = widget.showDetails ?? false;
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

  Widget _firstWidget() {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: widget.category == null &&
                      widget.shop == null &&
                      widget.products == null
                  ? null
                  : IconButton(
                      icon: Icon(
                        YvanIcons.left_arrow_1,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
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
                    size: size(context).height / 40.0,
                  ),
                ),
                IconButton(
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
                                    : Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                size(context).width / 30.0),
                                        child: StaggeredGridView.countBuilder(
                                            crossAxisCount: 4,
                                            staggeredTileBuilder: (int index) =>
                                                new StaggeredTile.count(
                                                    2,
                                                    index % 2 == 0
                                                        ? size(context).height /
                                                            195.0
                                                        : index % 3 == 0
                                                            ? size(context)
                                                                    .height /
                                                                220.0
                                                            : size(context)
                                                                    .height /
                                                                240.0),
                                            mainAxisSpacing:
                                                size(context).height / 22.0,
                                            crossAxisSpacing:
                                                size(context).width / 30.0,
                                            itemBuilder:
                                                (BuildContext context,
                                                        int index) =>
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (!recents.contains(
                                                            _data[index])) {
                                                          recents.add(
                                                              _data[index]);
                                                        }
                                                        setState(() {
                                                          showDetailsProduct =
                                                              true;
                                                          productCode =
                                                              _data[index].code;
                                                        });
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              height: index %
                                                                          2 ==
                                                                      0
                                                                  ? size(context)
                                                                          .height /
                                                                      2.3
                                                                  : index % 3 ==
                                                                          0
                                                                      ? size(context)
                                                                              .height /
                                                                          2.7
                                                                      : size(context)
                                                                              .height /
                                                                          3.1,
                                                              child: Stack(
                                                                fit: StackFit
                                                                    .expand,
                                                                children: [
                                                                  ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size(context).height /
                                                                              60),
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        imageUrl:
                                                                            imagePath(_data[index].photo),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                loader(),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            new Icon(Icons.error),
                                                                      )),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(size(context).height /
                                                                                60),
                                                                        color: Colors
                                                                            .black38),
                                                                  ),
                                                                  Positioned(
                                                                      bottom: size(context)
                                                                              .height /
                                                                          50.0,
                                                                      left: size(context)
                                                                              .height /
                                                                          80.0,
                                                                      child:
                                                                          Text(
                                                                        _data[index]
                                                                            .shopName,
                                                                        style: TextStyle(
                                                                            fontSize: size(context).height /
                                                                                70.0,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      )),
                                                                  Positioned(
                                                                    top: 0,
                                                                    left: 0.0,
                                                                    child: _data[index].newPrice ==
                                                                            0
                                                                        ? Container()
                                                                        : Container(
                                                                            margin:
                                                                                EdgeInsets.all(size(context).height / 200.0),
                                                                            padding:
                                                                                EdgeInsets.all(size(context).height / 50.0),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                                            child:
                                                                                Text(
                                                                              '- ${discountPercent(_data[index].oldPrice, _data[index].newPrice)}%',
                                                                              style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                  ),
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    right: 0,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (favoriteDescriptions.contains(_data[index].description) &&
                                                                              favoriteNames.contains(_data[index].name)) {
                                                                            favorites.remove(_data[index]);
                                                                            favoriteDescriptions.remove(_data[index].description);
                                                                            favoriteNames.remove(_data[index].name);
                                                                          } else {
                                                                            favorites.add(_data[index]);
                                                                            favoriteNames.add(_data[index].name);
                                                                            favoriteDescriptions.add(_data[index].description);
                                                                          }
                                                                          storeFavorite(
                                                                              favorites);
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                          margin: EdgeInsets.all(size(context).height / 100),
                                                                          padding: EdgeInsets.all(size(context).height / 100),
                                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                          child: Icon(
                                                                            favoriteDescriptions.contains(_data[index].description) && favoriteNames.contains(_data[index].name)
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            color: favoriteDescriptions.contains(_data[index].description) && favoriteNames.contains(_data[index].name)
                                                                                ? Colors.red.withOpacity(.9)
                                                                                : Colors.black54,
                                                                            size:
                                                                                size(context).height / 50,
                                                                          )),
                                                                    ),
                                                                  )
                                                                ],
                                                              )),
                                                          SizedBox(
                                                            height: size(
                                                                        context)
                                                                    .height /
                                                                200.0,
                                                          ),
                                                          Container(
                                                            width: size(context)
                                                                    .width /
                                                                2,
                                                            child: Text(
                                                              _data[index].name,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize:
                                                                      size(context)
                                                                              .height /
                                                                          50),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: size(
                                                                        context)
                                                                    .height /
                                                                200.0,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: size(context)
                                                                        .width /
                                                                    3.3,
                                                                child: Text(
                                                                  _data[index].newPrice ==
                                                                              null ||
                                                                          _data[index].newPrice ==
                                                                              0
                                                                      ? '${_data[index].oldPrice} XAF'
                                                                      : '${_data[index].newPrice} XAF',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          size(context).height /
                                                                              40,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              _data[index].newPrice ==
                                                                          null ||
                                                                      _data[index]
                                                                              .newPrice ==
                                                                          0
                                                                  ? Container()
                                                                  : Container(
                                                                      width:
                                                                          size(context).width /
                                                                              7,
                                                                      child:
                                                                          Text(
                                                                        _data[index]
                                                                            .oldPrice
                                                                            .toString(),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .red,
                                                                            decoration: TextDecoration
                                                                                .lineThrough,
                                                                            fontSize: size(context).height /
                                                                                75,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    )
                                                            ],
                                                          ),
                                                          Spacer(),
                                                        ],
                                                      ),
                                                    ),
                                            itemCount: _data.length));
                              }

                              return Center(
                                child: loader(),
                              );
                            },
                          )
                        :
                        // Products
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size(context).width / 30.0),
                            child: StaggeredGridView.countBuilder(
                                crossAxisCount: 4,
                                staggeredTileBuilder: (int index) =>
                                    new StaggeredTile.count(
                                        2,
                                        index % 2 == 0
                                            ? size(context).height / 195.0
                                            : index % 3 == 0
                                                ? size(context).height / 220.0
                                                : size(context).height / 240.0),
                                mainAxisSpacing: size(context).height / 22.0,
                                crossAxisSpacing: size(context).width / 30.0,
                                itemBuilder: (BuildContext context,
                                        int index) =>
                                    GestureDetector(
                                      onTap: () {
                                        if (!recents
                                            .contains(widget.products[index])) {
                                          recents.add(widget.products[index]);
                                        }
                                        setState(() {
                                          showDetailsProduct = true;
                                          productCode =
                                              widget.products[index].code;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              height: index % 2 == 0
                                                  ? size(context).height / 2.3
                                                  : index % 3 == 0
                                                      ? size(context).height /
                                                          2.7
                                                      : size(context).height /
                                                          3.1,
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size(context)
                                                                      .height /
                                                                  60),
                                                      child: CachedNetworkImage(
                                                        imageUrl: imagePath(
                                                            widget
                                                                .products[index]
                                                                .photo),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                loader(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            new Icon(
                                                                Icons.error),
                                                      )),
                                                  Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(size(
                                                                        context)
                                                                    .height /
                                                                60),
                                                        color: Colors.black38),
                                                  ),
                                                  Positioned(
                                                      bottom:
                                                          size(context).height /
                                                              50.0,
                                                      left:
                                                          size(context).height /
                                                              80.0,
                                                      child: Text(
                                                        widget.products[index]
                                                            .shopName,
                                                        style: TextStyle(
                                                            fontSize: size(
                                                                        context)
                                                                    .height /
                                                                70.0,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                  Positioned(
                                                    top: 0,
                                                    left: 0.0,
                                                    child:
                                                        widget.products[index]
                                                                    .newPrice ==
                                                                0
                                                            ? Container()
                                                            : Container(
                                                                margin: EdgeInsets.all(
                                                                    size(context)
                                                                            .height /
                                                                        200.0),
                                                                padding: EdgeInsets.all(
                                                                    size(context)
                                                                            .height /
                                                                        50.0),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child: Text(
                                                                  '- ${discountPercent(widget.products[index].oldPrice, widget.products[index].newPrice)}%',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (favoriteDescriptions
                                                                  .contains(widget
                                                                      .products[
                                                                          index]
                                                                      .description) &&
                                                              favoriteNames
                                                                  .contains(widget
                                                                      .products[
                                                                          index]
                                                                      .name)) {
                                                            favorites.remove(
                                                                widget.products[
                                                                    index]);
                                                            favoriteDescriptions
                                                                .remove(widget
                                                                    .products[
                                                                        index]
                                                                    .description);
                                                            favoriteNames
                                                                .remove(widget
                                                                    .products[
                                                                        index]
                                                                    .name);
                                                          } else {
                                                            favorites.add(
                                                                widget.products[
                                                                    index]);
                                                            favoriteNames.add(
                                                                widget
                                                                    .products[
                                                                        index]
                                                                    .name);
                                                            favoriteDescriptions
                                                                .add(widget
                                                                    .products[
                                                                        index]
                                                                    .description);
                                                          }
                                                          storeFavorite(
                                                              favorites);
                                                        });
                                                      },
                                                      child: Container(
                                                          margin: EdgeInsets.all(
                                                              size(context)
                                                                      .height /
                                                                  100),
                                                          padding: EdgeInsets
                                                              .all(size(context)
                                                                      .height /
                                                                  100),
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .white),
                                                          child: Icon(
                                                            favoriteDescriptions.contains(widget
                                                                        .products[
                                                                            index]
                                                                        .description) &&
                                                                    favoriteNames.contains(widget
                                                                        .products[
                                                                            index]
                                                                        .name)
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            color: favoriteDescriptions.contains(widget
                                                                        .products[
                                                                            index]
                                                                        .description) &&
                                                                    favoriteNames.contains(widget
                                                                        .products[
                                                                            index]
                                                                        .name)
                                                                ? Colors.red
                                                                    .withOpacity(
                                                                        .9)
                                                                : Colors
                                                                    .black54,
                                                            size: size(context)
                                                                    .height /
                                                                50,
                                                          )),
                                                    ),
                                                  )
                                                ],
                                              )),
                                          SizedBox(
                                            height:
                                                size(context).height / 200.0,
                                          ),
                                          Container(
                                            width: size(context).width / 2,
                                            child: Text(
                                              widget.products[index].name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize:
                                                      size(context).height /
                                                          50),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                size(context).height / 200.0,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width:
                                                    size(context).width / 3.3,
                                                child: Text(
                                                  widget.products[index]
                                                                  .newPrice ==
                                                              null ||
                                                          widget.products[index]
                                                                  .newPrice ==
                                                              0
                                                      ? '${widget.products[index].oldPrice} XAF'
                                                      : '${widget.products[index].newPrice} XAF',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          size(context).height /
                                                              40,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              widget.products[index].newPrice ==
                                                          null ||
                                                      widget.products[index]
                                                              .newPrice ==
                                                          0
                                                  ? Container()
                                                  : Container(
                                                      width:
                                                          size(context).width /
                                                              7,
                                                      child: Text(
                                                        widget.products[index]
                                                            .oldPrice
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontSize: size(
                                                                        context)
                                                                    .height /
                                                                75,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                            ],
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                    ),
                                itemCount: widget.products.length))))));
  }

  Widget _secondWidget() {
    productSpecs = fetchProduct(widget.productCode ?? productCode);
    _reviews = fetchAllReviews(widget.productCode ?? productCode);
    return Scaffold(
        body: FutureBuilder(
      future: productSpecs,
      builder: (context, snapshot) {
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
          product = Product.fromJson(snapshot.data['produit']);
          pics = snapshot.data['photos']['pics'];
          nbrPics = snapshot.data['photos']['count'];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: GestureDetector(
                  onTap: () => setState(() => showDetailsProduct = false),
                  child: Padding(
                    padding: EdgeInsets.only(top: size(context).height / 30),
                    child: Icon(
                      YvanIcons.left_arrow_1,
                      color: Colors.black,
                    ),
                  ),
                ),
                floating: true,
                pinned: false,
                primary: false,
                expandedHeight: size(context).height * .65,
                flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {
                        _selectedItem = index;
                      });
                    },
                    itemCount: nbrPics,
                    itemBuilder: (BuildContext context, index) {
                      return CachedNetworkImage(
                        imageUrl: imagePath('${pics[index]}'),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => loader(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      );
                    },
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize:
                      Size(size(context).width, size(context).height / 50.0),
                  child: _pageSelectedIndex(nbrPics),
                ),
                actions: [
                  IconButton(
                      padding: EdgeInsets.only(top: size(context).height / 30),
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
                              padding:
                                  EdgeInsets.all(size(context).height / 200),
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
                      onPressed: () => Navigator.pushNamed(context, 'cart')),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (favoriteDescriptions
                                  .contains(product.description) &&
                              favoriteNames.contains(product.name)) {
                            favorites.remove(product);
                            favoriteDescriptions.remove(product.description);
                            favoriteNames.remove(product.name);
                          } else {
                            favorites.add(product);
                            favoriteNames.add(product.name);
                            favoriteDescriptions.add(product.description);
                          }
                          storeFavorite(favorites);
                        });
                      },
                      padding: EdgeInsets.only(top: size(context).height / 30),
                      icon: Icon(
                        favoriteNames.contains(product.name) &&
                                favoriteDescriptions
                                    .contains(product.description)
                            ? Icons.favorite
                            : YvanIcons.heart,
                        color: favoriteNames.contains(product.name) &&
                                favoriteDescriptions
                                    .contains(product.description)
                            ? Colors.red[500]
                            : Colors.black87,
                      )),
                ],
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(size(context).height / 10.0))),
                  margin: EdgeInsets.symmetric(
                      vertical: size(context).height / 45.0,
                      horizontal: size(context).height / 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size(context).height / 40.0)),
                          Text(
                              'XAF ${product.newPrice != 0 && product.newPrice != null ? product.newPrice : product.oldPrice}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size(context).height / 50.0))
                        ],
                      ),
                      SizedBox(height: size(context).height / 100.0),
                      Text(product.description),
                      SizedBox(height: size(context).height / 40.0),
                      /* Text('Couleur'),
                      SizedBox(height: size(context).height / 100.0),
                      Container(
                        height: size(context).height / 25,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _colorIndex = index;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: size(context).height / 100.0),
                                  padding: EdgeInsets.all(
                                      size(context).height / 50.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _colors[index]),
                                ),
                                index != _colorIndex
                                    ? Container()
                                    : Positioned(
                                        right: 0,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right:
                                                  size(context).height / 100.0),
                                          padding: EdgeInsets.all(
                                              size(context).height / 150.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.0),
                                              shape: BoxShape.circle,
                                              color: Colors.purpleAccent),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          itemCount: _colors.length,
                        ),
                      ),
                      SizedBox(height: size(context).height / 40.0),
                      Text('Taille'),
                      SizedBox(height: size(context).height / 100.0),
                      Container(
                        height: size(context).height / 20,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _sizeIndex = index;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  EdgeInsets.all(size(context).height / 70.0),
                              margin: EdgeInsets.only(
                                  right: size(context).height / 100.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _sizeIndex
                                      ? Colors.black
                                      : Colors.grey[100]),
                              child: Text(
                                _sizes[index],
                                style: TextStyle(
                                    color: index == _sizeIndex
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          itemCount: _sizes.length,
                        ),
                      ),
                      SizedBox(height: size(context).height / 40.0),
                       */
                      Text('Metadonnees'),
                      SizedBox(height: size(context).height / 100.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size(context).width / 2.6,
                            child: Text(
                              'Boutique: ${product.shopName ?? 'Non renseigne'}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: size(context).width / 4,
                            child: Text(
                              'Disponible: ${product.available}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Container(
                            width: size(context).width / 7,
                            child: Text(
                              'Note: ${product.rate}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder(
                          future: _reviews,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Center(
                                  child: Text(
                                    'Impossible de charger les avis pour le moment',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              List data = [];
                              double rate = 0.0;
                              int rateInt = 0;
                              for (var item in snapshot.data) {
                                if (!data.contains(item)) {
                                  rate += double.parse(item['note']);
                                  data.add(item);
                                }
                              }
                              rate /= data.isNotEmpty ? data.length : 1;
                              rateInt = rate.toInt();
                              return data.isEmpty
                                  ? SizedBox(
                                      height: 0.0,
                                    )
                                  : Column(
                                      children: <Widget>[
                                        SizedBox(
                                            height:
                                                size(context).height / 40.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Avis (${data.length})',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              Spacer(),
                                              Text(
                                                'Tout voir',
                                                style:
                                                    TextStyle(fontSize: 13.0),
                                              ),
                                              Icon(
                                                YvanIcons.arrow_drop_right_line,
                                                size: 10.0,
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                rate.toString().length > 3
                                                    ? '${rate.toString().substring(0, 3)}'
                                                    : rate.toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              renderStars(rateInt)
                                            ],
                                          ),
                                        ),
                                        Container(
                                            height: 81,
                                            child: PageView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: data.length,
                                                itemBuilder:
                                                    (context, int index) {
                                                  return Column(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: 71.0,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 40.0,
                                                                width: 40.0,
                                                                child: ClipOval(
                                                                    child: Image.network(imagePath(data[index]['client']['photo'] ??
                                                                            data[index]['client']['gender'] ==
                                                                                'femme'
                                                                        ? 'users/avatar2.jpg'
                                                                        : 'users/avatar.jpg'))),
                                                              ),
                                                              SizedBox(
                                                                width: 20.0,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      '${data[index]['client']['name']}'),
                                                                  Text(
                                                                      '${format(data[index]['date'])}'),
                                                                  Text(data[index]['message']
                                                                              .length >
                                                                          20
                                                                      ? '${data[index]['message'].substring(0, 20)}...'
                                                                      : data[index]
                                                                          [
                                                                          'message']),
                                                                ],
                                                              ),
                                                              Spacer(),
                                                              Column(
                                                                children: <
                                                                    Widget>[
                                                                  Spacer(),
                                                                  renderStars(int
                                                                      .parse(data[
                                                                              index]
                                                                          [
                                                                          'note'])),
                                                                  Spacer()
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }))
                                      ],
                                    );
                            }

                            return loader();
                          }),
                      /* SizedBox(height: size(context).height / 40.0),
                      Row(
                        children: <Widget>[
                          Text(
                            'Date estimee de livraison:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Spacer(),
                          Text(
                            '${estimateDate()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ), */
                      SizedBox(height: size(context).height / 40.0),
                      Row(
                        children: [
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => setState(() {
                                if (canAddProduct(product)) {
                                  if (cartDescription.contains(
                                          product.description.toLowerCase()) &&
                                      cartNames.contains(
                                          product.name.toLowerCase())) {
                                    quantities[cartNames.lastIndexOf(
                                        product.name.toLowerCase())]++;
                                    setCartQuantities(quantities);
                                    evaluateTotal(product.newPrice == 0 ||
                                            product.newPrice == null
                                        ? product.oldPrice
                                        : product.newPrice);
                                  } else {
                                    cartNames.add(product.name.toLowerCase());
                                    cartDescription
                                        .add(product.description.toLowerCase());
                                    carts.add(product);
                                    storeProductCart(carts);
                                    quantities.add(1);
                                    setCartQuantities(quantities);
                                    length = carts.length;
                                    setCartLength(length);
                                    evaluateTotal(product.newPrice == 0 ||
                                            product.newPrice == null
                                        ? product.oldPrice
                                        : product.newPrice);
                                    commandShopIds.add(product.shopId);
                                    shopNames.add(product.shopName);
                                    setNumberOfShopInCommand();
                                  }

                                  new Future.delayed(new Duration(seconds: 2),
                                      () {
                                    SweetAlert.show(context,
                                        subtitle: 'Produit ajoute au panier',
                                        style: SweetAlertStyle.success);
                                  });
                                } else {
                                  new Future.delayed(new Duration(seconds: 2),
                                      () {
                                    SweetAlert.show(context,
                                        subtitle:
                                            'Vous ne pouvez pas commander\n        dans plus de 2 boutiques',
                                        style: SweetAlertStyle.confirm);
                                  });
                                }
                                SweetAlert.show(context,
                                    title: 'Un instant...',
                                    subtitle: 'Ajout du produit au panier',
                                    style: SweetAlertStyle.loading);
                              }),
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 50.0)),
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    vertical: size(context).height / 40.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      YvanIcons.bag,
                                      color: Colors.white,
                                      size: size(context).height / 35.0,
                                    ),
                                    SizedBox(
                                      width: size(context).width / 45.0,
                                    ),
                                    Text(
                                      'ajouter au panier',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              size(context).height / 45.0),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size(context).width / 40.0,
                          ),
                          GestureDetector(
                            onTap: () => launchWhatsApp(
                                phone: snapshot.data['produit']['admin_phone'],
                                message:
                                    "Bonjour M./Mme. ${snapshot.data['produit']['admin_name']}. J'aimerais echanger avec vous concernant le produit ${product.name}. Ma question est"),
                            child: Card(
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    size(context).height / 50.0),
                              ),
                              child: Container(
                                width: size(context).width / 5,
                                height: size(context).height / 13.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 50.0),
                                  child: Image.asset('img/whatsapp.png',
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ]))
            ],
          );
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black12,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.only(top: size(context).height / 30),
                    child: Icon(
                      YvanIcons.left_arrow_1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              floating: true,
              pinned: false,
              primary: false,
              expandedHeight: size(context).height / 1.8,
              flexibleSpace: loader(),
              actions: [
                IconButton(
                    padding: EdgeInsets.only(top: size(context).height / 30),
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
                    onPressed: () => Navigator.pushNamed(context, 'cart')),
                IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.only(top: size(context).height / 30),
                    icon: Icon(
                      YvanIcons.heart,
                      color: Colors.black87,
                    )),
              ],
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Center(
                child: loader(),
              )
            ]))
          ],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return showDetailsProduct ? _secondWidget() : _firstWidget();
  }
}
