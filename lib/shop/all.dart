import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/addons/search.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/products/all.dart';
import 'package:new_bos_app/services/homeService.dart';
import 'package:sweetalert/sweetalert.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Future<List<Shop>> shops;

  @override
  void initState() {
    super.initState();
    shops = fetchShops();
  }

  _fetchData() {
    shops = fetchShops();
    Navigator.popAndPushNamed(context, '/shop');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.black.withOpacity(.7),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
        ],
        title: Text(
          'Boutiques',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: FutureBuilder(
            future: shops,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              if (snapshot.hasData) {
                return Container(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          await _refreshData();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size(context).width / 30),
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 4 / 7,
                                      crossAxisSpacing:
                                          size(context).width / 50),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AllProductPage(
                                                shop: snapshot.data[index],
                                              ))),
                                  onDoubleTap: () {
                                    setState(() {
                                      if (favoritesShops
                                          .contains(snapshot.data[index])) {
                                        favoritesShops
                                            .remove(snapshot.data[index]);
                                      } else {
                                        favoritesShops
                                            .add(snapshot.data[index]);
                                      }
                                    });
                                    storeFavoriteShops(favoritesShops);
                                  },
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: double.infinity,
                                          height: size(context).height / 3,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size(context).height /
                                                              60),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imagePath(snapshot
                                                            .data[index]
                                                            .photo ??
                                                        'shops/clothes_shop.jpg'),
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            loader(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                    margin: EdgeInsets.all(
                                                        size(context).height /
                                                            100),
                                                    padding: EdgeInsets.all(
                                                        size(context).height /
                                                            100),
                                                    decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        color: Colors.white),
                                                    child: Icon(
                                                      favoritesShops.contains(
                                                              snapshot.data[
                                                                  index])
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: favoritesShops
                                                              .contains(
                                                                  snapshot.data[
                                                                      index])
                                                          ? Colors.red
                                                          : Colors.black,
                                                      size: size(context)
                                                              .height /
                                                          50,
                                                    )),
                                              )
                                            ],
                                          )),
                                      Container(
                                        width: size(context).width / 2,
                                        child: Text(
                                          snapshot.data[index].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  size(context).height / 50),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                              '${parseIntToDouble(snapshot.data[index].rate)}'),
                                          SizedBox(
                                            width: size(context).width / 40.0,
                                          ),
                                          renderStars(
                                              snapshot.data[index].rate),
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

              return Center(
                child: loader(),
              );
            },
          )),
    );
  }
}
