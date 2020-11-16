//Subpage product
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/services/shopService.dart';

class FavoriteShops extends StatefulWidget {
  final bool canPop;
  const FavoriteShops({Key key, this.canPop}) : super(key: key);
  @override
  _FavoriteShopsState createState() => _FavoriteShopsState();
}

class _FavoriteShopsState extends State<FavoriteShops> {
  Future products;
  String _code, _shopName;
  bool _show;

  @override
  void initState() {
    super.initState();
    _show = false;
  }

  _searchRedirection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  Widget firstWidget() {
    return Scaffold(
        appBar: AppBar(
          leading: widget.canPop ?? false
              ? IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    YvanIcons.left_arrow_1,
                    color: Colors.black,
                  ),
                )
              : null,
          centerTitle: true,
          title: Text(
            'Boutiques favorites',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RouterPage(
                            index: 2,
                            canPopFavorite: true,
                            isProduct: true,
                          ))),
              child: Icon(
                YvanIcons.heart,
                size: size(context).height / 40.0,
                color: Colors.black,
              ),
            ),
            IconButton(
                icon: Icon(
                  YvanIcons.delete,
                  size: size(context).height / 40.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  favoritesShops.clear();
                  setState(() {
                    storeFavoriteShops(favoritesShops);
                  });
                })
          ],
        ),
        body: favoritesShops.isEmpty
            ? Center(
                child: Text(
                  'Aucune boutique favoris',
                ),
              )
            : Container(
                child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: size(context).width / 30),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4 / 7,
                        crossAxisSpacing: size(context).width / 50),
                    itemCount: favoritesShops.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(() {
                          _show = true;
                          _code = favoritesShops[index].code;
                          _shopName = favoritesShops[index].name;
                        }),
                        onDoubleTap: () {
                          setState(() {
                            if (favoritesShops
                                .contains(favoritesShops[index])) {
                              favoritesShops.remove(favoritesShops[index]);
                            } else {
                              favoritesShops.add(favoritesShops[index]);
                            }
                          });
                          storeFavoriteShops(favoritesShops);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: double.infinity,
                                height: size(context).height / 3,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size(context).height / 60),
                                        child: CachedNetworkImage(
                                          imageUrl: imagePath(
                                              favoritesShops[index].photo ??
                                                  'shops/clothes_shop.jpg'),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              loader(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          favoritesShops.removeAt(index);
                                          storeFavoriteShops(favoritesShops);
                                        }),
                                        child: Container(
                                            margin: EdgeInsets.all(
                                                size(context).height / 100),
                                            padding: EdgeInsets.all(
                                                size(context).height / 100),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: Icon(
                                              YvanIcons.delete,
                                              color: Colors.black,
                                              size: size(context).height / 50,
                                            )),
                                      ),
                                    )
                                  ],
                                )),
                            Container(
                              width: size(context).width / 2,
                              child: Text(
                                favoritesShops[index].name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size(context).height / 50),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    '${parseIntToDouble(favoritesShops[index].rate)}'),
                                SizedBox(
                                  width: size(context).width / 40.0,
                                ),
                                renderStars(favoritesShops[index].rate),
                              ],
                            ),
                            SizedBox(
                              height: size(context).height / 50.0,
                            )
                          ],
                        ),
                      );
                    }),
              )));
  }

  Widget secondWidget() {
    products = fetchShopProducts(_code);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  YvanIcons.left_arrow_1,
                  color: Colors.black,
                ),
                onPressed: () => setState(() => _show = false),
              ),
              primary: false,
              automaticallyImplyLeading: false,
              title: Text(_shopName,
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
            body: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: FutureBuilder(
                  future: products,
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
                      List _data = [];
                      _data = snapshot.data;
                      return snapshot.data.isEmpty
                          ? Center(child: Text('Aucun produit '))
                          : Container(
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
                                                  : size(context).height /
                                                      240.0),
                                  mainAxisSpacing: size(context).height / 22.0,
                                  crossAxisSpacing: size(context).width / 30.0,
                                  itemBuilder: (BuildContext context,
                                          int index) =>
                                      GestureDetector(
                                        onTap: () {
                                          if (!recents.contains(_data[index])) {
                                            recents.add(_data[index]);
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RouterPage(
                                                        index: 1,
                                                        showDetails: true,
                                                        code: _data[index].code,
                                                      )));
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
                                                        borderRadius: BorderRadius
                                                            .circular(size(
                                                                        context)
                                                                    .height /
                                                                60),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: imagePath(
                                                              _data[index]
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
                                                          color:
                                                              Colors.black38),
                                                    ),
                                                    Positioned(
                                                        bottom: size(context)
                                                                .height /
                                                            50.0,
                                                        left: size(context)
                                                                .height /
                                                            80.0,
                                                        child: Text(
                                                          _data[index].shopName,
                                                          style: TextStyle(
                                                              fontSize: size(
                                                                          context)
                                                                      .height /
                                                                  70.0,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    Positioned(
                                                      top: 0,
                                                      left: 0.0,
                                                      child: _data[index]
                                                                  .newPrice ==
                                                              0
                                                          ? Container()
                                                          : Container(
                                                              margin: EdgeInsets
                                                                  .all(size(context)
                                                                          .height /
                                                                      200.0),
                                                              padding: EdgeInsets
                                                                  .all(size(context)
                                                                          .height /
                                                                      50.0),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: Text(
                                                                '- ${discountPercent(_data[index].oldPrice, _data[index].newPrice)}%',
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
                                                                    .contains(_data[
                                                                            index]
                                                                        .description) &&
                                                                favoriteNames
                                                                    .contains(_data[
                                                                            index]
                                                                        .name)) {
                                                              favorites.remove(
                                                                  _data[index]);
                                                              favoriteDescriptions
                                                                  .remove(_data[
                                                                          index]
                                                                      .description);
                                                              favoriteNames
                                                                  .remove(_data[
                                                                          index]
                                                                      .name);
                                                            } else {
                                                              favorites.add(
                                                                  _data[index]);
                                                              favoriteNames.add(
                                                                  _data[index]
                                                                      .name);
                                                              favoriteDescriptions
                                                                  .add(_data[
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
                                                              favoriteDescriptions.contains(
                                                                          _data[index]
                                                                              .description) &&
                                                                      favoriteNames.contains(
                                                                          _data[index]
                                                                              .name)
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color: favoriteDescriptions.contains(
                                                                          _data[index]
                                                                              .description) &&
                                                                      favoriteNames.contains(
                                                                          _data[index]
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
                                                _data[index].name,
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
                                                    _data[index].newPrice ==
                                                                null ||
                                                            _data[index]
                                                                    .newPrice ==
                                                                0
                                                        ? '${_data[index].oldPrice} XAF'
                                                        : '${_data[index].newPrice} XAF',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: size(context)
                                                                .height /
                                                            40,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                _data[index].newPrice == null ||
                                                        _data[index].newPrice ==
                                                            0
                                                    ? Container()
                                                    : Container(
                                                        width: size(context)
                                                                .width /
                                                            7,
                                                        child: Text(
                                                          _data[index]
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
                                  itemCount: _data.length));
                    }

                    return Center(
                      child: loader(),
                    );
                  },
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return !_show ? firstWidget() : secondWidget();
  }
}
