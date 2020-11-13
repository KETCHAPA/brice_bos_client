import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/auth/login.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/common/removeAccent.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/orders/final.dart';
import 'package:new_bos_app/orders/payment1.dart';
import 'package:new_bos_app/payment/mtn.dart';
import 'package:new_bos_app/payment/orange.dart';
import 'package:new_bos_app/services/commandService.dart';
import 'package:new_bos_app/services/paymentService.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sweetalert/sweetalert.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int page;
  int _userId;
  String _qties1 = '',
      _qties2 = '',
      _proIds1 = '',
      _proIds2 = '',
      _shopStringIds1 = '',
      _shopStringIds2 = '';
  int isSelectedPayment2 = -1,
      isSelectedLivraison2 = -1,
      importancePay2 = 2,
      importanceLiv2 = 2,
      _payId2 = 0,
      _payPrice2 = 0,
      _livPrice2 = 0,
      _livId2 = 0;
  Future<List> payments2;
  Future<List> livraisons2;
  List _secondfilteredShop = [], _secondfilteredShopNames = [];
  bool secondCanDelete;
  String secondPaymentPrices1 = '', secondPaymentPrices2 = '';
  int secondAmount1 = 0, secondAmount2 = 0;
  ProgressDialog progress;
  int isSelectedPayment = -1,
      isSelectedLivraison = -1,
      importancePay = 2,
      importanceLiv = 2;
  Future<List> payments;
  Future<List> livraisons;
  List _filteredShop = [], _filteredShopNames = [];
  String payName = '', livName = '';
  int payId = 0, livId = 0, livPrice = 0, payPrice = 0;
  String prices1 = '', prices2 = '';
  int amount1 = 0, amount2 = 0;

  @override
  void initState() {
    super.initState();
    page = 0;
    om.clear();
    momo.clear();
    for (var item in commandShopIds) {
      if (!_filteredShop.contains(item)) {
        _filteredShop.add(item);
      }
    }
    for (var item in shopNames) {
      if (!_filteredShopNames.contains(item)) {
        _filteredShopNames.add(item);
      }
    }
  }

  void changeQuantity(int price, String sign) {
    setState(() {
      setTotal(price, sign);
    });
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

  _fetchData() {
    setState(() {
      payments = getPaymentWay(_filteredShop[0]);
      livraisons = getLivraisonWay(_filteredShop[0]);
    });
  }

  createData() async {
    progress = loadingWidget(context);
    progress.show();
    var _shopName = carts[0].shopName;
    for (var i = 0; i < carts.length; i++) {
      if (_shopName == carts[i].shopName) {
        prices1 +=
            '${carts[i].newPrice == null || carts[i].newPrice == 0 ? carts[i].oldPrice : carts[i].newPrice} ,';
        amount1 += carts[i].newPrice == null || carts[i].newPrice == 0
            ? carts[i].oldPrice * quantities[i]
            : carts[i].newPrice * quantities[i];
      } else {
        prices2 +=
            '${carts[i].newPrice == null || carts[i].newPrice == 0 ? carts[i].oldPrice : carts[i].newPrice} ,';
        amount2 += carts[i].newPrice == null || carts[i].newPrice == 0
            ? carts[i].oldPrice * quantities[i]
            : carts[i].newPrice * quantities[i];
      }
    }
    Map<String, dynamic> params = Map<String, dynamic>();
    params['pro_ids'] = _proIds1;
    params['quantities'] = _qties1;
    params['prices'] = prices1;
    params['amount'] = (amount1 + livPrice + payPrice).toString();
    await storeCart(params).then((data) async {
      if (data != null) {
        Map<String, dynamic> params = Map<String, dynamic>();
        params['client_id'] = _userId.toString();
        params['cart_id'] = data.id.toString();
        params['shop_id'] = _shopStringIds1;
        await storeCommand(params).then((data1) async {
          if (data1 != null) {
            String _commandCode1 = data1.code;
            Map<String, dynamic> params = Map<String, dynamic>();
            params['ser_id'] = payId.toString();
            params['importance'] = '2';
            await storeCommandServices(params, _commandCode1)
                .then((data) async {
              if (data != null) {
                progress.show();
                params['ser_id'] = livId.toString();
                params['importance'] = '2';
                await storeCommandServices(params, _commandCode1)
                    .then((data) async {
                  if (data != null) {
                    om.isNotEmpty
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrangeMoneyPayment(
                                      command1: data1,
                                      shops: commandShopIds,
                                      items: carts,
                                      quantities: quantities,
                                      pay1: payPrice,
                                      liv1: livPrice,
                                      mailCode1: _commandCode1,
                                      names: shopNames,
                                    )))
                        : momo.isNotEmpty
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MoMoPayment(
                                          command1: data1,
                                          pay1: payPrice,
                                          liv1: livPrice,
                                          shops: commandShopIds,
                                          items: carts,
                                          mailCode1: _commandCode1,
                                          quantities: quantities,
                                          names: shopNames,
                                        )))
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DeliveryPage(
                                          code1: _commandCode1,
                                        )));
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
                                          'Impossible de valider le mode de livraison de la boutique ${shopNames[0]}. Verifier votre connexion internet et reessayer.'))
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
                                      'Impossible de confirmer la paiement de la boutique ${shopNames[0]}. Verifier votre connexion internet et reessayer.'))
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

  _fetchData2() {
    setState(() {
      payments2 = getPaymentWay(_secondfilteredShop[1]);
      livraisons2 = getLivraisonWay(_secondfilteredShop[1]);
    });
  }

  createData2() async {
    progress = loadingWidget(context);
    progress.show();
    
    var _shopName = carts[0].shopName;
    for (var i = 0; i < carts.length; i++) {
      if (_shopName == carts[i].shopName) {
        secondPaymentPrices1 +=
            '${carts[i].newPrice == null || carts[i].newPrice == 0 ? carts[i].oldPrice : carts[i].newPrice} ,';
        secondAmount1 += carts[i].newPrice == null || carts[i].newPrice == 0
            ? carts[i].oldPrice * quantities[i]
            : carts[i].newPrice * quantities[i];
      } else {
        secondPaymentPrices2 +=
            '${carts[i].newPrice == null || carts[i].newPrice == 0 ? carts[i].oldPrice : carts[i].newPrice} ,';
        secondAmount2 += carts[i].newPrice == null || carts[i].newPrice == 0
            ? carts[i].oldPrice * quantities[i]
            : carts[i].newPrice * quantities[i];
      }
    }
    Map<String, dynamic> params = Map<String, dynamic>();
    params['pro_ids'] = _proIds1;
    params['quantities'] = _qties1;
    params['prices'] = secondPaymentPrices1;
    params['amount'] = (secondAmount1 + livPrice + payPrice).toString();
    await storeCart(params).then((data) async {
      if (data != null) {
        Map<String, dynamic> params = Map<String, dynamic>();
        params['client_id'] = _userId.toString();
        params['cart_id'] = data.id.toString();
        params['shop_id'] = _shopStringIds1;
        await storeCommand(params).then((data1) async {
          if (data1 != null) {
            String _commandCode1 = data1.code;
            Map<String, dynamic> params = Map<String, dynamic>();
            params['ser_id'] = payId.toString();
            params['importance'] = '2';
            await storeCommandServices(params, _commandCode1)
                .then((data) async {
              if (data != null) {
                progress.show();
                params['ser_id'] = livId.toString();
                params['importance'] = '2';
                await storeCommandServices(params, _commandCode1)
                    .then((data) async {
                  if (data != null) {
                    if (_livId2 != null) {
                      Map<String, dynamic> params = Map<String, dynamic>();
                      params['pro_ids'] = _proIds2;
                      params['quantities'] = _qties2;
                      params['prices'] = secondPaymentPrices2;
                      params['amount'] =
                          (secondAmount2 + _livPrice2 + _payPrice2).toString();
                      await storeCart(params).then((data) async {
                        if (data != null) {
                          Map<String, dynamic> params = Map<String, dynamic>();
                          params['client_id'] = _userId.toString();
                          params['cart_id'] = data.id.toString();
                          params['shop_id'] = _shopStringIds2;
                          await storeCommand(params).then((data2) async {
                            if (data2 != null) {
                              String _commandCode2 = data2.code;
                              Map<String, dynamic> params =
                                  Map<String, dynamic>();
                              params['ser_id'] = _payId2.toString();
                              params['importance'] = '3';
                              await storeCommandServices(params, _commandCode2)
                                  .then((data) async {
                                if (data != null) {
                                  progress.show();
                                  params['ser_id'] = _livId2.toString();
                                  params['importance'] = '3';
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
                                                        shops: commandShopIds,
                                                        items: carts,
                                                        quantities: quantities,
                                                        pay1: payPrice,
                                                        liv1: livPrice,
                                                        pay2: _payPrice2,
                                                        liv2: _livPrice2,
                                                        mailCode1:
                                                            _commandCode1,
                                                        mailCode2:
                                                            _commandCode2,
                                                        names: shopNames,
                                                      )))
                                          : momo.isNotEmpty
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MoMoPayment(
                                                            command1: data1,
                                                            command2: data2,
                                                            pay1: payPrice,
                                                            liv1: livPrice,
                                                            pay2: _payPrice2,
                                                            liv2: _livPrice2,
                                                            shops:
                                                                commandShopIds,
                                                            items: carts,
                                                            mailCode1:
                                                                _commandCode1,
                                                            mailCode2:
                                                                _commandCode2,
                                                            quantities:
                                                                quantities,
                                                            names: shopNames,
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
                                                            'Impossible de valider le mode de livraison de la boutique ${shopNames[1]}. Verifier votre connexion internet et reessayer.'))
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
                                                        'Impossible de confirmer la paiement de la boutique ${shopNames[1]}. Verifier votre connexion internet et reessayer.'))
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
                                        shops: commandShopIds,
                                        items: carts,
                                        quantities: carts,
                                        pay1: payPrice,
                                        liv1: livPrice,
                                        pay2: _payPrice2,
                                        liv2: _livPrice2,
                                        mailCode1: _commandCode1,
                                        names: shopNames,
                                      )))
                          : momo.isNotEmpty
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MoMoPayment(
                                            command1: data1,
                                            pay1: payPrice,
                                            liv1: livPrice,
                                            pay2: _payPrice2,
                                            liv2: _livPrice2,
                                            shops: commandShopIds,
                                            items: carts,
                                            mailCode1: _commandCode1,
                                            quantities: carts,
                                            names: shopNames,
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
                                          'Impossible de valider le mode de livraison de la boutique ${shopNames[0]}. Verifier votre connexion internet et reessayer.'))
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
                                      'Impossible de confirmer la paiement de la boutique ${shopNames[0]}. Verifier votre connexion internet et reessayer.'))
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

  void _deleteItem(int index) {
    setState(() {
      cartNames.removeAt(index);
      cartDescription.removeAt(index);
      commandShopIds.removeAt(index);
      shopNames.removeAt(index);
      setNumberOfShopInCommand();
      setTotal(
          carts[index].newPrice == 0 || carts[index].newPrice == null
              ? carts[index].oldPrice * quantities[index]
              : carts[index].newPrice * quantities[index],
          '-');
      quantities.removeAt(index);
      length--;
      setCartLength(length);
      setCartQuantities(quantities);
      carts.removeAt(index);
      storeProductCart(carts);
    });
  }

  Widget firstPage() {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Panier',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  YvanIcons.delete,
                  size: size(context).height / 40.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    carts = [];
                    quantities = [];
                    cartDescription = [];
                    cartNames = [];
                    length = 0;
                    clearShopInCommand();
                    setCartLength(length);
                    clearTotal();
                    setCartQuantities(quantities);
                    storeProductCart(carts);
                  });
                })
          ],
        ),
        floatingActionButton: carts.isEmpty
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: size(context).width / 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: size(context).width / 3.5,
                      margin: EdgeInsets.only(left: size(context).width / 30.0),
                      child: Text(
                        'XAF $total',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: size(context).height / 50.0),
                      ),
                    ),
                    FutureBuilder(
                        future: isLogged(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data
                                ? FutureBuilder(
                                    future: getCurrentUser(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasData) {
                                        _userId = userSnapshot.data['id'];
                                        return carts.isEmpty
                                            ? sweetalert(
                                                context: context,
                                                withConfirmation: false,
                                                subtitle:
                                                    'Votre panier est vide',
                                                type: SweetAlertStyle.confirm)
                                            : FloatingActionButton.extended(
                                                icon: Icon(
                                                  YvanIcons
                                                      .money_dollar_circle_line,
                                                  color: Colors.orange,
                                                  size: size(context).height /
                                                      50.0,
                                                ),
                                                label: Text(
                                                  'Proceder au paiement',
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize:
                                                          size(context).height /
                                                              50.0),
                                                ),
                                                tooltip:
                                                    'Finaliser votre achat',
                                                backgroundColor: Colors.black,
                                                onPressed: () =>
                                                    setState(() => page = 1));
                                      }
                                      return Center(
                                        child: loader(),
                                      );
                                    })
                                : FloatingActionButton.extended(
                                    icon: Icon(
                                      YvanIcons.user_6_line,
                                      color: Colors.orange,
                                      size: size(context).height / 50.0,
                                    ),
                                    label: Text(
                                      'Connectez-vous',
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontSize:
                                              size(context).height / 50.0),
                                    ),
                                    tooltip: 'Connectez-vous pour continuer',
                                    backgroundColor: Colors.black,
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage(
                                                redirection: widget))));
                          }
                          return Center(
                            child: loader(),
                          );
                        })
                  ],
                ),
              ),
        body: FutureBuilder(
            future: getCartTotal(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
              if (snapshot.hasData) {
                return carts.isEmpty
                    ? Center(child: Text('Vous n\'avez aucun article'))
                    : ListView.builder(
                        itemCount: carts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.fromLTRB(
                              size(context).width / 20,
                              0,
                              size(context).width / 30,
                              size(context).height / 20,
                            ),
                            height: size(context).height / 7,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: double.infinity,
                                  width: size(context).width / 4,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          size(context).height / 50.0),
                                      child: CachedNetworkImage(
                                        imageUrl: imagePath(carts[index].photo),
                                        placeholder: (context, url) => loader(),
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )),
                                ),
                                SizedBox(
                                  width: size(context).height / 40,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: size(context).width / 1.7,
                                      child: Text(
                                        carts[index].name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size(context).height / 40.0,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: size(context).width / 2,
                                          child: Text(
                                            'Vendeur: ${carts[index].shopName}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.brown,
                                              fontSize:
                                                  size(context).height / 42.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (quantities[index] == 1) {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      actions: <Widget>[
                                                        OutlineButton(
                                                          child: Text(
                                                            'Continuer',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {
                                                              _deleteItem(
                                                                  index);
                                                            });
                                                          },
                                                        ),
                                                        OutlineButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            'Annuler',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        )
                                                      ],
                                                      title:
                                                          Text('Suppression'),
                                                      content: Text(
                                                          'Vous allez supprimer cet article'),
                                                    );
                                                  });
                                            } else {
                                              setState(() {
                                                quantities[index]--;
                                                setCartQuantities(quantities);
                                                changeQuantity(
                                                    carts[index].newPrice ==
                                                                0 ||
                                                            carts[index]
                                                                    .newPrice ==
                                                                null
                                                        ? carts[index].oldPrice
                                                        : carts[index].newPrice,
                                                    '-');
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                size(context).height / 100.0),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.remove,
                                              size: size(context).height / 60.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size(context).height / 50.0,
                                        ),
                                        Text(
                                          quantities[index].toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  size(context).height / 45.0),
                                        ),
                                        SizedBox(
                                          width: size(context).height / 50.0,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              quantities[index]++;
                                              setCartQuantities(quantities);
                                              changeQuantity(
                                                  carts[index].newPrice == 0 ||
                                                          carts[index]
                                                                  .newPrice ==
                                                              null
                                                      ? carts[index].oldPrice
                                                      : carts[index].newPrice,
                                                  '+');
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                size(context).height / 100.0),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.add,
                                              size: size(context).height / 60.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size(context).height / 15.0,
                                        ),
                                        Text(
                                          'XAF ${quantities[index] * (carts[index].newPrice == null || carts[index].newPrice == 0 ? carts[index].oldPrice : carts[index].newPrice)}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  size(context).height / 45.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Spacer()
                              ],
                            ),
                          );
                        });
              }
              return Center(
                child: loader(),
              );
            }));
  }

  Widget secondPage() {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(YvanIcons.left_arrow_1, color: Colors.black),
            onPressed: () => setState(() => page = 0),
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
                          '${carts.length} Elements',
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
                          itemCount: carts.length,
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
                                            imageUrl:
                                                imagePath(carts[index].photo),
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
                                              carts[index].name,
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
                                            carts[index].description,
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
                                            'XAF ${quantities[index] * (carts[index].newPrice == null || carts[index].newPrice == 0 ? carts[index].oldPrice : carts[index].newPrice)}',
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
                                            carts[index].shopName,
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
                                            quantities[index].toString(),
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
                          var _shopNames = carts[0].shopName;
                          for (var i = 0; i < carts.length; i++) {
                            if (carts[i].shopName == _shopNames) {
                              _proIds1 += '${carts[i].id.toString()} ,';
                              _shopStringIds1 +=
                                  '${carts[i].shopId.toString()} ,';
                              _qties1 += '${quantities[i].toString()} ,';
                            } else {
                              _proIds2 += '${carts[i].id.toString()} ,';
                              _shopStringIds2 +=
                                  '${carts[i].shopId.toString()} ,';
                              _qties2 += '${quantities[i].toString()} ,';
                            }
                          }
                          setState(() {
                            page = 2;
                          });
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

  Widget thirdPage() {
    payments = getPaymentWay(_filteredShop[0]);
    livraisons = getLivraisonWay(_filteredShop[0]);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => setState(() => page = 1),
          icon: Icon(
            YvanIcons.left_arrow_1,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Boutique ${_filteredShopNames[0]}',
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: isSelectedPayment == -1 || isSelectedLivraison == -1
            ? null
            : () {
                _filteredShop.length > 1
                    ? setState(() => page = 3)
                    : createData();
              },
        child: Container(
          child: Text('Suivant >>>',
              style: TextStyle(
                  fontSize: size(context).height / 40.0,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshData();
          setState(() => page = 2);
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
                                  payId = snapshot.data[index]['id'];
                                  payPrice =
                                      int.parse(snapshot.data[index]['price']);
                                  payName = snapshot.data[index]['name'];
                                });
                                if (removeDiacritics(
                                            snapshot.data[index]['name'])
                                        .toLowerCase()
                                        .contains('orange money') ||
                                    removeDiacritics(
                                            snapshot.data[index]['description'])
                                        .toLowerCase()
                                        .contains('orange money')) {
                                  if (om.isEmpty) {
                                    om.add(1);
                                  }
                                } else {
                                  if (om.isNotEmpty) {
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
                                  if (momo.isEmpty) {
                                    momo.add(1);
                                  }
                                } else {
                                  if (momo.isNotEmpty) {
                                    momo.removeLast();
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
                                        livId = snapshot.data[index]['id'];
                                        livPrice = int.parse(
                                            snapshot.data[index]['price']);
                                        livName = snapshot.data[index]['name'];
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

  Widget fourthPage() {
    secondCanDelete = false;
    for (var item in commandShopIds) {
      if (!_secondfilteredShop.contains(item)) {
        _secondfilteredShop.add(item);
      }
    }
    for (var item in shopNames) {
      if (!_secondfilteredShopNames.contains(item)) {
        _secondfilteredShopNames.add(item);
      }
    }
    payments2 = getPaymentWay(_secondfilteredShop[1]);
    livraisons2 = getLivraisonWay(_secondfilteredShop[1]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => setState(() => page = 2),
          icon: Icon(
            YvanIcons.left_arrow,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Boutique ${_secondfilteredShopNames[1]}',
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: isSelectedPayment2 == -1 || isSelectedLivraison2 == -1
            ? null
            : createData2,
        child: Container(
          child: Text('Suivant >>>',
              style: TextStyle(
                  fontSize: size(context).height / 40.0,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData2();
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
                  future: payments2,
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
                                  isSelectedPayment2 = index;
                                  _payId2 = snapshot.data[index]['id'];
                                  _payPrice2 =
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
                                    secondCanDelete = true;
                                  }
                                } else {
                                  if (secondCanDelete) {
                                    momo.removeLast();
                                    secondCanDelete = false;
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
                                    color: index == isSelectedPayment2
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
                                          color: index == isSelectedPayment2
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
                                      index == isSelectedPayment2
                                          ? Icons.check
                                          : Icons.brightness_1,
                                      color: index == isSelectedPayment2
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
                  future: livraisons2,
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
                                        isSelectedLivraison2 = index;
                                        _livId2 = snapshot.data[index]['id'];
                                        _livPrice2 = int.parse(
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
                                          color: index == isSelectedLivraison2
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
                                                color: index ==
                                                        isSelectedLivraison2
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
                                                color: index ==
                                                        isSelectedLivraison2
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Icon(
                                            index == isSelectedLivraison2
                                                ? Icons.check
                                                : Icons.check,
                                            color: index == isSelectedLivraison2
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

  @override
  Widget build(BuildContext context) {
    return page == 0
        ? firstPage()
        : page == 1 ? secondPage() : page == 2 ? thirdPage() : fourthPage();
  }
}
