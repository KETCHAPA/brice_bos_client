import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/model/clients.dart';
import 'package:new_bos_app/model/commands.dart';
import 'package:new_bos_app/orders/final.dart';
import 'package:new_bos_app/orders/payment1.dart';
import 'package:new_bos_app/services/onlineService.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:uuid/uuid.dart';

class MoMoPayment extends StatefulWidget {
  final List names, items, quantities, shops;
  final int pay1, pay2, liv1, liv2;
  final String mailCode1, mailCode2;
  final Command command1, command2;
  MoMoPayment(
      {@required this.command1,
      this.command2,
      @required this.names,
      @required this.items,
      @required this.shops,
      this.pay2,
      @required this.pay1,
      @required this.liv1,
      this.liv2,
      @required this.mailCode1,
      this.mailCode2,
      @required this.quantities});
  @override
  _MoMoPaymentState createState() => _MoMoPaymentState();
}

class _MoMoPaymentState extends State<MoMoPayment> {
  TextEditingController _numberController = TextEditingController();
  Future<Client> saler, saler2;
  int _amount1 = 0, _amount2 = 0;
  List _filteredShop = [], _filteredShopNames = [];

  @override
  void initState() {
    super.initState();
    var _shopNames = widget.items[0].shopName;
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].shopName == _shopNames) {
        _amount1 +=
            widget.items[i].newPrice == 0 || widget.items[i].newPrice == null
                ? widget.items[i].oldPrice * widget.quantities[i]
                : widget.items[i].newPrice * widget.quantities[i];
      } else {
        _amount2 +=
            widget.items[i].newPrice == 0 || widget.items[i].newPrice == null
                ? widget.items[i].oldPrice * widget.quantities[i]
                : widget.items[i].newPrice * widget.quantities[i];
      }

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
      if (momo.contains(1)) {
        saler = getSalerInfo(_filteredShop[0]);
      }
      if (momo.contains(2)) {
        saler2 = getSalerInfo(_filteredShop[1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width / 2 - 15,
              child: OutlineButton(
                child: Text(
                  'Retour',
                  style: TextStyle(color: Colors.red),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ),
            Spacer(),
            Container(
              width: MediaQuery.of(context).size.width / 2 - 15,
              child: OutlineButton(
                child: Text('Valider'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                onPressed: () async {
                  ProgressDialog progress = loadingWidget(context);
                  _numberController.text.isEmpty
                      ? sweetalert(
                          context: context,
                          withConfirmation: false,
                          subtitle: 'Renseignez le numero debiteur',
                          type: SweetAlertStyle.confirm)
                      : showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'Non',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                    'Oui',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () async {
                                    double _amountToPay = 0;
                                    bool onCommand1 = false, onCommand2 = false;
                                    var uuid = Uuid();
                                    if (om.contains(1)) {
                                      _amountToPay +=
                                          widget.liv1 + widget.pay1 + _amount1;
                                    }
                                    if (om.contains(2)) {
                                      _amountToPay +=
                                          widget.liv2 + widget.pay2 + _amount2;
                                    }
                                    _amountToPay += _amountToPay * 1 / 100;
                                    Map<String, dynamic> params =
                                        Map<String, dynamic>();
                                    params['amount'] = _amountToPay.toString();
                                    params['operator'] = 'MTN_CMR';
                                    if (onCommand1) {
                                      params['command1'] = widget.command1.code;
                                      onCommand1 = true;
                                    }
                                    if (onCommand2) {
                                      params['command2'] = widget.command2.code;
                                      onCommand2 = true;
                                    }
                                    params['phone'] = _numberController.text;
                                    params['client_reference'] = uuid.v4();
                                    progress.show();
                                    await cashIn(params).then((data) async {
                                      progress.hide();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DeliveryPage(
                                                    code2: widget.mailCode2,
                                                    code1: widget.mailCode1,
                                                  )));
                                    });
                                  },
                                ),
                              ],
                              title: Text('Confirmation'),
                              content: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text('Confirmer la transaction ?'),
                              ),
                            );
                          });
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Paiement Mobile Money"),
        backgroundColor: Color(0xfffecd1b),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            saler == null
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text('${_filteredShopNames[0].toUpperCase()}'),
                            SizedBox(
                              height: 5.0,
                            ),
                            FutureBuilder(
                                future: saler,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('${snapshot.error}'),
                                    );
                                  }
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text('Montant total:'),
                                            Spacer(),
                                            Text(
                                                '${_amount1 + widget.liv1 + widget.pay1} Frs CFA')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text('Numero de livraison'),
                                            Spacer(),
                                            Text('${snapshot.data.phone}')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text('Nom du beneficiaire'),
                                            Spacer(),
                                            Text('${snapshot.data.name}')
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  return Center(
                                      child: CircularProgressIndicator());
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
            saler2 == null
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text('${_filteredShopNames[1].toUpperCase()}'),
                            SizedBox(
                              height: 5.0,
                            ),
                            FutureBuilder(
                                future: saler2,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('${snapshot.error}'),
                                    );
                                  }
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text('Montant total:'),
                                            Spacer(),
                                            Text(
                                                '${_amount2 + widget.liv2 + widget.pay2} Frs CFA')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text('Numero de livraison'),
                                            Spacer(),
                                            Text('${snapshot.data.phone}')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text('Nom du beneficiaire'),
                                            Spacer(),
                                            Text('${snapshot.data.name}')
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  return Center(
                                      child: CircularProgressIndicator());
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text('Numero a debiter'),
                      SizedBox(
                        height: 5.0,
                      ),
                      ListTile(
                          leading: Container(
                              width: 70.0,
                              child: Image.asset(
                                'img/MoMo.jpg',
                                fit: BoxFit.cover,
                              )),
                          title: FutureBuilder(
                            future: getCurrentUser(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
                                  controller: _numberController,
                                  textInputAction: TextInputAction.done,
                                  onTap: () {
                                    _numberController.text =
                                        snapshot.data['phone'];
                                  },
                                  onChanged: (value) {
                                    _numberController.text = value;
                                  },
                                  decoration: InputDecoration(
                                      hintText: snapshot.data['phone']),
                                );
                              }
                              return TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
                                  controller: _numberController,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) {
                                    _numberController.text = value;
                                  },
                                  decoration: InputDecoration());
                            },
                          ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
