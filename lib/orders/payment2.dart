import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/common/removeAccent.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/orders/final.dart';
import 'package:new_bos_app/orders/payment1.dart';
import 'package:new_bos_app/payment/mtn.dart';
import 'package:new_bos_app/payment/orange.dart';
import 'package:new_bos_app/services/commandService.dart';
import 'package:new_bos_app/services/paymentService.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sweetalert/sweetalert.dart';

class Payment2Page extends StatefulWidget {
  Payment2Page(
      {@required this.shops,
      @required this.items,
      @required this.quantities,
      @required this.names,
      @required this.amount,
      @required this.proIds1,
      @required this.proIds2,
      @required this.qties1,
      @required this.qties2,
      @required this.shopStringIds1,
      @required this.shopStringIds2,
      @required this.pay1Id,
      @required this.liv1Id,
      @required this.pay1Name,
      @required this.liv1Price,
      @required this.pay1Price,
      @required this.liv1Name,
      @required this.userId});

  final List items, quantities;
  final List shops, names;
  final String qties1,
      proIds1,
      shopStringIds1,
      qties2,
      proIds2,
      shopStringIds2,
      liv1Name,
      pay1Name;
  final int userId, amount, liv1Price, pay1Id, liv1Id, pay1Price;
  @override
  _Payment2PageState createState() => _Payment2PageState();
}

class _Payment2PageState extends State<Payment2Page> {
  ProgressDialog progress;
  int isSelectedPayment = -1,
      isSelectedLivraison = -1,
      importancePay = 2,
      importanceLiv = 2,
      _payId = 0,
      _payPrice = 0,
      _livPrice = 0,
      _livId = 0;
  Future<List> payments;
  Future<List> livraisons;
  List _filteredShop = [], _filteredShopNames = [];
  bool canDelete;
  String prices1 = '', prices2 = '';
  int amount1 = 0, amount2 = 0;

  @override
  void initState() {
    super.initState();
    canDelete = false;
    for (var item in widget.shops) {
      if (!_filteredShop.contains(item)) {
        _filteredShop.add(item);
      }
    }
    for (var item in widget.names) {
      if (!_filteredShopNames.contains(item)) {
        _filteredShopNames.add(item);
      }
    }
    payments = getPaymentWay(_filteredShop[1]);
    livraisons = getLivraisonWay(_filteredShop[1]);
  }

  _fetchData() {
    setState(() {
      payments = getPaymentWay(_filteredShop[1]);
      livraisons = getLivraisonWay(_filteredShop[1]);
    });
  }

  createData() async {
    progress = loadingWidget(context);
    progress.show();
    var _shopName = widget.items[0].shopName;
    for (var i = 0; i < widget.items.length; i++) {
      if (_shopName == widget.items[i].shopName) {
        prices1 +=
            '${widget.items[i].newPrice == null || widget.items[i].newPrice == 0 ? widget.items[i].oldPrice : widget.items[i].newPrice} ,';
        amount1 +=
            widget.items[i].newPrice == null || widget.items[i].newPrice == 0
                ? widget.items[i].oldPrice * widget.quantities[i]
                : widget.items[i].newPrice * widget.quantities[i];
      } else {
        prices2 +=
            '${widget.items[i].newPrice == null || widget.items[i].newPrice == 0 ? widget.items[i].oldPrice : widget.items[i].newPrice} ,';
        amount2 +=
            widget.items[i].newPrice == null || widget.items[i].newPrice == 0
                ? widget.items[i].oldPrice * widget.quantities[i]
                : widget.items[i].newPrice * widget.quantities[i];
      }
    }
    Map<String, dynamic> params = Map<String, dynamic>();
    params['pro_ids'] = widget.proIds1;
    params['quantities'] = widget.qties1;
    params['prices'] = prices1;
    params['amount'] =
        (amount1 + widget.liv1Price + widget.pay1Price).toString();
    print('debut de la premiere commande');
    await storeCart(params).then((data) async {
      if (data != null) {
        Map<String, dynamic> params = Map<String, dynamic>();
        params['client_id'] = widget.userId.toString();
        params['cart_id'] = data.id.toString();
        params['shop_id'] = widget.shopStringIds1;
        print('commande');
        await storeCommand(params).then((data1) async {
          if (data1 != null) {
            String _commandCode1 = data1.code;
            Map<String, dynamic> params = Map<String, dynamic>();
            params['ser_id'] = widget.pay1Id.toString();
            params['importance'] = '2';
            print('commande service 1');
            await storeCommandServices(params, _commandCode1)
                .then((data) async {
              if (data != null) {
                progress.show();
                params['ser_id'] = widget.liv1Id.toString();
                params['importance'] = '2';
                print('commande service 2');
                await storeCommandServices(params, _commandCode1)
                    .then((data) async {
                  if (data != null) {
                    if (_livId != null) {
                      Map<String, dynamic> params = Map<String, dynamic>();
                      params['pro_ids'] = widget.proIds2;
                      params['quantities'] = widget.qties2;
                      params['prices'] = prices2;
                      params['amount'] =
                          (amount2 + _livPrice + _payPrice).toString();
                      print('debut de la deuxieme commande');
                      await storeCart(params).then((data) async {
                        if (data != null) {
                          Map<String, dynamic> params = Map<String, dynamic>();
                          params['client_id'] = widget.userId.toString();
                          params['cart_id'] = data.id.toString();
                          params['shop_id'] = widget.shopStringIds2;
                          print('commande 2');
                          await storeCommand(params).then((data2) async {
                            if (data2 != null) {
                              String _commandCode2 = data2.code;
                              Map<String, dynamic> params =
                                  Map<String, dynamic>();
                              params['ser_id'] = _payId.toString();
                              params['importance'] = '3';
                              print('commande service 3');
                              await storeCommandServices(params, _commandCode2)
                                  .then((data) async {
                                if (data != null) {
                                  progress.show();
                                  params['ser_id'] = _livId.toString();
                                  params['importance'] = '3';
                                  print('commande service 4');
                                  await storeCommandServices(
                                          params, _commandCode2)
                                      .then((data) {
                                    progress.hide();
                                    if (data != null) {
                                      om.isNotEmpty
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrangeMoneyPayment(
                                                        command1: data1,
                                                        command2: data2,
                                                        shops: widget.shops,
                                                        items: widget.items,
                                                        quantities:
                                                            widget.quantities,
                                                        pay1: widget.pay1Price,
                                                        liv1: widget.liv1Price,
                                                        pay2: _payPrice,
                                                        liv2: _livPrice,
                                                        mailCode1:
                                                            _commandCode1,
                                                        mailCode2:
                                                            _commandCode2,
                                                        names: widget.names,
                                                      )))
                                          : momo.isNotEmpty
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MoMoPayment(
                                                            command1: data1,
                                                            command2: data2,
                                                            pay1: widget
                                                                .pay1Price,
                                                            liv1: widget
                                                                .liv1Price,
                                                            pay2: _payPrice,
                                                            liv2: _livPrice,
                                                            shops: widget.shops,
                                                            items: widget.items,
                                                            mailCode1:
                                                                _commandCode1,
                                                            mailCode2:
                                                                _commandCode2,
                                                            quantities: widget
                                                                .quantities,
                                                            names: widget.names,
                                                          )))
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DeliveryPage(
                                                            code1:
                                                                _commandCode1,
                                                            code2:
                                                                _commandCode2,
                                                          )));
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                actions: <Widget>[
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Ok')),
                                                ],
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0))),
                                                elevation: 15.0,
                                                title: Text('Erreur'),
                                                content: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.warning,
                                                      color: Colors.red,
                                                      size: 30.0,
                                                    ),
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.1,
                                                        child: Text(
                                                            'Impossible de valider le mode de livraison de la boutique ${widget.names[1]}. Verifier votre connexion internet et reessayer.'))
                                                  ],
                                                ),
                                              ));
                                    }
                                  });
                                } else {
                                  progress.hide();
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            actions: <Widget>[
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Ok')),
                                            ],
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0))),
                                            elevation: 15.0,
                                            title: Text('Erreur'),
                                            content: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.warning,
                                                  color: Colors.red,
                                                  size: 30.0,
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Container(
                                                    width: 400.0,
                                                    child: Text(
                                                        'Impossible de confirmer la paiement de la boutique ${widget.names[1]}. Verifier votre connexion internet et reessayer.'))
                                              ],
                                            ),
                                          ));
                                }
                              });
                            } else {
                              progress.hide();
                              SweetAlert.show(context,
                                  title: 'Une erreur est survenue',
                                  subtitle:
                                      'Verifier votre connexion internet et reessayer.',
                                  style: SweetAlertStyle.error);
                            }
                          });
                        } else {
                          progress.hide();
                          SweetAlert.show(context,
                              title: 'Une erreur est survenue',
                              subtitle:
                                  'Verifier votre connexion internet et reessayer.',
                              style: SweetAlertStyle.error);
                        }
                        return null;
                      });
                    } else {
                      progress.hide();
                      om.isNotEmpty
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrangeMoneyPayment(
                                        command1: data1,
                                        shops: widget.shops,
                                        items: widget.items,
                                        quantities: widget.quantities,
                                        pay1: widget.pay1Price,
                                        liv1: widget.liv1Price,
                                        pay2: _payPrice,
                                        liv2: _livPrice,
                                        mailCode1: _commandCode1,
                                        names: widget.names,
                                      )))
                          : momo.isNotEmpty
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MoMoPayment(
                                            command1: data1,
                                            pay1: widget.pay1Price,
                                            liv1: widget.liv1Price,
                                            pay2: _payPrice,
                                            liv2: _livPrice,
                                            shops: widget.shops,
                                            items: widget.items,
                                            mailCode1: _commandCode1,
                                            quantities: widget.quantities,
                                            names: widget.names,
                                          )))
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DeliveryPage(code1: _commandCode1)));
                    }
                  } else {
                    progress.hide();
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Ok')),
                              ],
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              elevation: 15.0,
                              title: Text('Erreur'),
                              content: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      child: Text(
                                          'Impossible de valider le mode de livraison de la boutique ${widget.names[0]}. Verifier votre connexion internet et reessayer.'))
                                ],
                              ),
                            ));
                  }
                });
              } else {
                progress.hide();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Ok')),
                          ],
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          elevation: 15.0,
                          title: Text('Erreur'),
                          content: Row(
                            children: <Widget>[
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 30.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Container(
                                  width: 400.0,
                                  child: Text(
                                      'Impossible de confirmer la paiement de la boutique ${widget.names[0]}. Verifier votre connexion internet et reessayer.'))
                            ],
                          ),
                        ));
              }
            });
          } else {
            progress.hide();
            SweetAlert.show(context,
                title: 'Une erreur est survenue',
                subtitle: 'Verifier votre connexion internet et reessayer.',
                style: SweetAlertStyle.error);
          }
        });
      } else {
        progress.hide();
        SweetAlert.show(context,
            title: 'Une erreur est survenue',
            subtitle: 'Verifier votre connexion internet et reessayer.',
            style: SweetAlertStyle.error);
      }
      return null;
    });
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
          'Boutique ${_filteredShopNames[1]}',
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: isSelectedPayment == -1 || isSelectedLivraison == -1
            ? null
            : createData,
        child: Container(
          child: Text('Suivant >>>',
              style: TextStyle(
                  fontSize: size(context).height / 40.0,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: size(context).height / 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  'Mode de paiement:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: size(context).height / 40.0,
                      fontWeight: FontWeight.bold),
                ),
                FutureBuilder(
                  future: payments,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Une erreur est survenue. Rafraichissez la page'),
                      );
                    }
                    if (snapshot.hasData) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 70.0 * snapshot.data.length,
                        child: ListView.builder(
                          physics: ScrollPhysics(parent: null),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  isSelectedPayment = index;
                                  _payId = snapshot.data[index]['id'];
                                  _payPrice =
                                      int.parse(snapshot.data[index]['price']);
                                });
                                if (removeDiacritics(
                                            snapshot.data[index]['name'])
                                        .toLowerCase()
                                        .contains('orange money') ||
                                    removeDiacritics(
                                            snapshot.data[index]['description'])
                                        .toLowerCase()
                                        .contains('orange money')) {
                                  if (om.length == 1) {
                                    om.add(2);
                                  }
                                } else {
                                  if (om.length > 1) {
                                    om.removeLast();
                                  }
                                }

                                if (removeDiacritics(
                                            snapshot.data[index]['name'])
                                        .toLowerCase()
                                        .contains('mobile money') ||
                                    removeDiacritics(
                                            snapshot.data[index]['description'])
                                        .toLowerCase()
                                        .contains('mobile money')) {
                                  if (momo.length < 2) {
                                    momo.add(2);
                                    canDelete = true;
                                  }
                                } else {
                                  if (canDelete) {
                                    momo.removeLast();
                                    canDelete = false;
                                  }
                                }

                                print('OM $om');
                                print('MoMo $momo');
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: size(context).height / 70.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: size(context).height / 50.0,
                                    vertical: size(context).height / 70.0),
                                decoration: BoxDecoration(
                                    color: index == isSelectedPayment
                                        ? Colors.black
                                        : Colors.white,
                                    border: Border.all(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(
                                        size(context).height / 10.0)),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      snapshot.data[index]['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: index == isSelectedPayment
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    SizedBox(
                                      width: size(context).width / 100.0,
                                    ),
                                    Text(
                                      snapshot.data[index]['price'] == null ||
                                              snapshot.data[index]['price'] ==
                                                  '0'
                                          ? '(Gratuit)'
                                          : '(XAF ${snapshot.data[index]['price']})',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Icon(
                                      index == isSelectedPayment
                                          ? Icons.check
                                          : Icons.brightness_1,
                                      color: index == isSelectedPayment
                                          ? Colors.deepOrangeAccent
                                          : Colors.white.withOpacity(.1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return Center(
                      child: loader(),
                    );
                  },
                ),
                SizedBox(
                  height: size(context).height / 40.0,
                ),
                Text(
                  'Mode de livraison:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: size(context).height / 40.0,
                      fontWeight: FontWeight.bold),
                ),
                FutureBuilder(
                  future: livraisons,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('${snapshot.error}'),
                      );
                    }
                    if (snapshot.hasData) {
                      return Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10.0),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 70.0 * snapshot.data.length,
                              child: ListView.builder(
                                physics: ScrollPhysics(parent: null),
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        isSelectedLivraison = index;
                                        _livId = snapshot.data[index]['id'];
                                        _livPrice = int.parse(
                                            snapshot.data[index]['price']);
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              size(context).height / 70.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              size(context).height / 50.0,
                                          vertical:
                                              size(context).height / 70.0),
                                      decoration: BoxDecoration(
                                          color: index == isSelectedLivraison
                                              ? Colors.black
                                              : Colors.white,
                                          border:
                                              Border.all(color: Colors.black87),
                                          borderRadius: BorderRadius.circular(
                                              size(context).height / 10.0)),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            snapshot.data[index]['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    index == isSelectedLivraison
                                                        ? Colors.white
                                                        : Colors.black),
                                          ),
                                          SizedBox(
                                            width: size(context).width / 100.0,
                                          ),
                                          Text(
                                            snapshot.data[index]['price'] ==
                                                        null ||
                                                    snapshot.data[index]
                                                            ['price'] ==
                                                        '0'
                                                ? '(Gratuit)'
                                                : '(XAF ${snapshot.data[index]['price']})',
                                            style: TextStyle(
                                                color:
                                                    index == isSelectedLivraison
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Icon(
                                            index == isSelectedLivraison
                                                ? Icons.check
                                                : Icons.check,
                                            color: index == isSelectedLivraison
                                                ? Colors.deepOrangeAccent
                                                : Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: loader(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
