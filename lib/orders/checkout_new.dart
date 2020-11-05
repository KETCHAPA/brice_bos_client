import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/orders/payment1.dart';

class CheckOutNew extends StatefulWidget {
  final List items, quantities;
  final int total;
  final int userId;
  CheckOutNew(
      {this.userId,
      @required this.items,
      @required this.total,
      @required this.quantities});
  @override
  _CheckOutNewState createState() => _CheckOutNewState();
}

class _CheckOutNewState extends State<CheckOutNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(YvanIcons.left_arrow_1, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder(
          future: getCartTotal(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(
                  left: size(context).width / 20.0,
                  right: size(context).width / 20.0,
                  bottom: size(context).height / 50.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facturation',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size(context).height / 30.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.items.length} Elements',
                          style:
                              TextStyle(fontSize: size(context).height / 60.0),
                        ),
                        Icon(YvanIcons.delete_1)
                      ],
                    ),
                    SizedBox(
                      height: size(context).height / 70.0,
                    ),
                    Divider(),
                    SizedBox(
                      height: size(context).height / 70.0,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: size(context).height / 6,
                              margin: EdgeInsets.symmetric(
                                  vertical: size(context).height / 100.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: size(context).width / 3.7,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size(context).height / 50.0),
                                          child: CachedNetworkImage(
                                            imageUrl: imagePath(
                                                widget.items[index].photo),
                                            placeholder: (context, url) =>
                                                loader(),
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ))),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size(context).height / 100.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: size(context).width / 2,
                                            child: Text(
                                              widget.items[index].name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0),
                                            )),
                                        SizedBox(
                                          height: size(context).height / 200.0,
                                        ),
                                        Container(
                                          width: size(context).width / 2,
                                          child: Text(
                                            widget.items[index].description,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: size(context).height /
                                                    55.0),
                                          ),
                                        ),
                                        SizedBox(
                                          height: size(context).height / 100.0,
                                        ),
                                        Container(
                                          width: size(context).width / 2,
                                          child: Text(
                                            'XAF ${widget.quantities[index] * (widget.items[index].newPrice == null || widget.items[index].newPrice == 0 ? widget.items[index].oldPrice : widget.items[index].newPrice)}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: size(context).height /
                                                    50.0),
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          width: size(context).width / 2,
                                          child: Text(
                                            widget.items[index].shopName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size(context).height / 30.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0, vertical: 3.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: size(context).height / 50.0,
                                          ),
                                          SizedBox(
                                            height:
                                                size(context).height / 100.0,
                                          ),
                                          Text(
                                            widget.quantities[index].toString(),
                                            style: TextStyle(
                                                fontSize:
                                                    size(context).height / 50.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height:
                                                size(context).height / 100.0,
                                          ),
                                          Icon(
                                            Icons.remove,
                                            size: size(context).height / 50.0,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: size(context).height / 70.0,
                    ),
                    Divider(),
                    SizedBox(
                      height: size(context).height / 70.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sous-total',
                          style:
                              TextStyle(fontSize: size(context).height / 45.0),
                        ),
                        Text(
                          'XAF ${snapshot.data}',
                          style:
                              TextStyle(fontSize: size(context).height / 45.0),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rabais',
                          style:
                              TextStyle(fontSize: size(context).height / 47.0),
                        ),
                        Text(
                          'XAF 0',
                          style:
                              TextStyle(fontSize: size(context).height / 47.0),
                        )
                      ],
                    ),
                    SizedBox(
                      height: size(context).height / 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size(context).height / 40.0),
                        ),
                        Text(
                          'XAF ${snapshot.data}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size(context).height / 40.0),
                        )
                      ],
                    ),
                    SizedBox(
                      height: size(context).height / 20.0,
                    ),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size(context).height / 10.0)),
                        onPressed: () {
                          String qties1 = '',
                              qties2 = '',
                              proIds1 = '',
                              proIds2 = '',
                              shopStringIds1 = '',
                              shopStringIds2 = '';
                          var _shopNames = widget.items[0].shopName;
                          for (var i = 0; i < widget.items.length; i++) {
                            if (widget.items[i].shopName == _shopNames) {
                              proIds1 += '${widget.items[i].id.toString()} ,';
                              shopStringIds1 +=
                                  '${widget.items[i].shopId.toString()} ,';
                              qties1 += '${widget.quantities[i].toString()} ,';
                            } else {
                              proIds2 += '${widget.items[i].id.toString()} ,';
                              shopStringIds2 +=
                                  '${widget.items[i].shopId.toString()} ,';
                              qties2 += '${widget.quantities[i].toString()} ,';
                            }
                          }
                          print('items=' +
                              widget.items.length.toString() +
                              ', qties1=' +
                              qties1 +
                              ', qties2=' +
                              qties2 +
                              ', proIds1=' +
                              proIds1 +
                              ', proIds2=' +
                              proIds2 +
                              ', ShopStringIds1=' +
                              shopStringIds1 +
                              ', ShopStringIds2=' +
                              shopStringIds2);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                        shops: commandShopIds,
                                        names: shopNames,
                                        amount: widget.total,
                                        proIds1: proIds1,
                                        proIds2: proIds2,
                                        qties1: qties1,
                                        qties2: qties2,
                                        shopStringIds1: shopStringIds1,
                                        shopStringIds2: shopStringIds2,
                                        userId: widget.userId,
                                        items: widget.items,
                                        quantities: widget.quantities,
                                      )));
                        },
                        color: Colors.black,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(size(context).height / 60),
                          child: Text(
                            'Suivant',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: size(context).height / 45.0),
                          ),
                        )),
                  ],
                ),
              );
            }
            return Center(
              child: loader(),
            );
          },
        ));
  }
}
