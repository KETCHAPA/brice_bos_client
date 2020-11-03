import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/orders/payment1.dart';

class CheckOutPage extends StatefulWidget {
  final List items, quantities;
  final int total;
  final int userId;
  CheckOutPage(
      {this.userId,
      @required this.items,
      @required this.total,
      @required this.quantities});
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  int paymentId;
  @override
  void initState() {
    super.initState();
    paymentId = 0;
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
        title: Text(
          'Finalisation',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            size(context).height / 30.0,
            size(context).height / 30.0,
            size(context).height / 30.0,
            size(context).height / 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Methode de paiement',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size(context).height / 40.0,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: size(context).height / 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    paymentId = 0;
                  }),
                  child: Card(
                    elevation: paymentId == 0 ? 50 : 0.0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(size(context).height / 40.0)),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(
                                size(context).height / 40.0)),
                        width: size(context).width / 4,
                        height: size(context).height / 9,
                        child: Image.asset('img/Cash.png')),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    paymentId = 1;
                  }),
                  child: Card(
                    elevation: paymentId == 1 ? 50 : 0.0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(size(context).height / 40.0)),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(
                                size(context).height / 40.0)),
                        width: size(context).width / 4,
                        height: size(context).height / 9,
                        child: Image.asset('img/OM.png')),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    paymentId = 2;
                  }),
                  child: Card(
                    elevation: paymentId == 2 ? 50 : 0.0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(size(context).height / 40.0)),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(
                                size(context).height / 40.0)),
                        width: size(context).width / 4,
                        height: size(context).height / 9,
                        child: Image.asset('img/MTN.png')),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size(context).height / 40,
            ),
            FutureBuilder(
                future: getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var user = snapshot.data;
                    return FutureBuilder(
                      future: getCartTotal(),
                      builder: (context, cartSnapshot) {
                        if (cartSnapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recapitulatif de la commande',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size(context).height / 40.0,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: size(context).height / 40,
                              ),
                              Container(
                                height: size(context).height / 2.25,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Card(
                                      elevation: 3.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size(context).height / 70)),
                                      child: Container(
                                        width: size(context).width * 0.6,
                                        padding: EdgeInsets.only(
                                            top: size(context).height / 50.0,
                                            right: size(context).height / 100.0,
                                            left: size(context).height / 100.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                  itemCount:
                                                      widget.items.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: size(context)
                                                                  .height /
                                                              40.0),
                                                      height:
                                                          size(context).height /
                                                              10,
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height:
                                                                double.infinity,
                                                            width: size(context)
                                                                    .width /
                                                                6,
                                                            child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        size(context).height /
                                                                            80.0),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl: imagePath(widget
                                                                      .items[
                                                                          index]
                                                                      .photo),
                                                                  placeholder:
                                                                      (context,
                                                                              url) =>
                                                                          loader(),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                )),
                                                          ),
                                                          SizedBox(
                                                            width: size(context)
                                                                    .height /
                                                                40,
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: size(context)
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  widget
                                                                      .items[
                                                                          index]
                                                                      .name,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        size(context).height /
                                                                            45.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'Qte: ${widget.quantities[index].toString()}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      size(context)
                                                                              .height /
                                                                          50.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                'XAF ${widget.quantities[index] * (widget.items[index].newPrice == null || widget.items[index].newPrice == 0 ? widget.items[index].oldPrice : widget.items[index].newPrice)}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        size(context).height /
                                                                            45.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                              width: size(context).width / 4,
                                              child: Text(
                                                'Client',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )),
                                          Container(
                                            width: size(context).width / 4,
                                            child: Text(
                                              user['name'].toUpperCase(),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Spacer(
                                            flex: 2,
                                          ),
                                          Container(
                                              width: size(context).width / 4,
                                              child: Text(
                                                'Sous-Total',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )),
                                          Container(
                                            width: size(context).width / 4,
                                            child: Text(
                                              'XAF ${cartSnapshot.data}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                              width: size(context).width / 4,
                                              child: Text(
                                                'Reduction',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )),
                                          Container(
                                            width: size(context).width / 4,
                                            child: Text(
                                              'XAF 0',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                              width: size(context).width / 4,
                                              child: Text(
                                                'Ristourne',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )),
                                          Container(
                                            width: size(context).width / 4,
                                            child: Text(
                                              'XAF 0',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                              width: size(context).width / 4,
                                              child: Text(
                                                'TVA',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )),
                                          Container(
                                            width: size(context).width / 4,
                                            child: Text(
                                              'XAF 0',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                              width: size(context).width / 4,
                                              child: Text(
                                                'Total',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )),
                                          Container(
                                            width: size(context).width / 4,
                                            child: Text(
                                              'XAF ${cartSnapshot.data}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      size(context).height /
                                                          45.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Expanded(
                          child: Center(
                            child: loader(),
                          ),
                        );
                      },
                    );
                  }
                  return Expanded(
                    child: Center(
                      child: loader(),
                    ),
                  );
                }),
            SizedBox(
              height: size(context).height / 40.0,
            ),
            RaisedButton(
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
                    shopStringIds1 += '${widget.items[i].shopId.toString()} ,';
                    qties1 += '${widget.quantities[i].toString()} ,';
                  } else {
                    proIds2 += '${widget.items[i].id.toString()} ,';
                    shopStringIds2 += '${widget.items[i].shopId.toString()} ,';
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
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(size(context).height / 50.0)),
              child: Container(
                alignment: Alignment.center,
                margin:
                    EdgeInsets.symmetric(vertical: size(context).height / 40.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Terminer',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: size(context).height / 45.0),
                    ),
                    SizedBox(
                      width: size(context).width / 45.0,
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                      size: size(context).height / 35.0,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
