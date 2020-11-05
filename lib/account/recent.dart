import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/products/show.dart';

class RecentlyProductPage extends StatefulWidget {
  @override
  _RecentlyProductPageState createState() => _RecentlyProductPageState();
}

class _RecentlyProductPageState extends State<RecentlyProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              YvanIcons.left_arrow_1,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          title: Text(
            'Vu Recemment',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: recents.isEmpty
            ? Center(
                child: Text(
                  'Aucun produit recemment vu',
                ),
              )
            : Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: size(context).width / 30),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4 / 7,
                        crossAxisSpacing: size(context).width / 50),
                    itemCount: recents.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (recents.contains(favorites[index])) {
                            recents.add(favorites[index]);
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowProduct(
                                        code: recents[index].code,
                                      )));
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
                                          imageUrl:
                                              imagePath(recents[index].photo),
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
                                          recents.removeAt(index);
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
                                              color: Colors.black54,
                                              size: size(context).height / 50,
                                            )),
                                      ),
                                    )
                                  ],
                                )),
                            Container(
                              width: size(context).width / 2,
                              child: Text(
                                recents[index].name,
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
                                    '${recents[index].oldPrice} XAF',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: size(context).height / 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                recents[index].newPrice == null ||
                                        recents[index].newPrice == 0
                                    ? Container()
                                    : Container(
                                        width: size(context).width / 7,
                                        child: Text(
                                          '${recents[index].newPrice} XAF',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.red,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize:
                                                  size(context).height / 75,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                              ],
                            ),
                            SizedBox(
                              height: size(context).height / 50.0,
                            )
                          ],
                        ),
                      );
                    })));
  }
}
