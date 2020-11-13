//Subpage product
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/shops.dart';

class FavoriteShops extends StatefulWidget {
  final bool canPop;

  const FavoriteShops({Key key, this.canPop}) : super(key: key);
  @override
  _FavoriteShopsState createState() => _FavoriteShopsState();
}

class _FavoriteShopsState extends State<FavoriteShops> {
  Future<List<Shop>> shops;

  @override
  Widget build(BuildContext context) {
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
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RouterPage(
                                      index: 1,
                                      shop: favoritesShops[index],
                                    ))),
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
}
