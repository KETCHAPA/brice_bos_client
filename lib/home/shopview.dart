import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/products/all.dart';
import 'package:new_bos_app/shop/all.dart';

class ShopView extends StatefulWidget {
  ShopView(this.shops);

  final List shops;

  @override
  _ShopViewState createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  @override
  Widget build(BuildContext context) {
    return widget.shops.isEmpty
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Boutiques',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size(context).height / 40.0),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ShopPage())),
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
                  itemCount: widget.shops.length > 4 ? 4 : widget.shops.length,
                  itemBuilder: (BuildContext context, index) {
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllProductPage(
                                        shop: widget.shops[index],
                                      )));
                        },
                        onDoubleTap: () {
                          setState(() {
                            if (favoritesShops.contains(widget.shops[index])) {
                              favoritesShops.remove(widget.shops[index]);
                            } else {
                              favoritesShops.add(widget.shops[index]);
                            }
                          });
                          storeFavoriteShops(favoritesShops);
                        },
                        child: Container(
                          width: size(context).width / 3,
                          margin: EdgeInsets.only(
                              left: index == 0 ? size(context).width / 30.0 : 0,
                              right: index == widget.shops.length
                                  ? 0
                                  : size(context).width / 30.0),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size(context).height / 100.0),
                                    child: CachedNetworkImage(
                                      imageUrl: imagePath(
                                          widget.shops[index].photo ??
                                              'shops/clothes_shop.jpg'),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => loader(),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error),
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 100.0),
                                  color: Colors.black38,
                                ),
                              ),
                              Positioned(
                                top: 0.0,
                                right: 0.0,
                                left: 0.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size(context).height / 100.0,
                                      vertical: size(context).height / 200.0),
                                  alignment: Alignment.center,
                                  height: size(context).height / 20.0,
                                  child: Text(
                                    widget.shops[index].name,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: size(context).height / 60.0),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size(context).height / 100.0,
                                      vertical: size(context).height / 200.0),
                                  alignment: Alignment.center,
                                  height: size(context).height / 20.0,
                                  child: Text(
                                    '10 Produits',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: size(context).height / 60.0),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0.0,
                                  right: 0.0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size(context).height / 100.0,
                                        vertical: size(context).height / 200.0),
                                    alignment: Alignment.center,
                                    height: size(context).height / 20.0,
                                    child: Icon(
                                      YvanIcons.heart,
                                      color: Colors.black,
                                      size: size(context).height / 50.0,
                                    ),
                                  ))
                            ],
                          ),
                        ));
                  },
                ),
              ),
            ],
          );
  }
}
