import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/services/commandService.dart';

class DeliveryPage extends StatefulWidget {
  DeliveryPage({this.code1, this.code2});
  final String code1;
  final String code2;
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  Future<bool> _mailSend1, _mailSend2;

  @override
  void initState() {
    super.initState();
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

    _mailSend1 = sendRecapMail(widget.code1);
    if (widget.code2 != null) {
      _mailSend2 = sendRecapMail(widget.code2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffecf5f5),
          leading: IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => RouterPage())),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          title: Text(
            'Commande enregistree',
            style: TextStyle(color: Colors.black),
          ),
        ),
        bottomNavigationBar: Container(
          color: Color(0xffecf5f5),
          padding: EdgeInsets.all(size(context).height / 100.0),
          child: RaisedButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => RouterPage())),
            color: Colors.black,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(size(context).height / 10.0)),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: size(context).height / 50.0),
              child: Text('Continuer mes achats',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        body: FutureBuilder(
            future: _mailSend1,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data) {
                  if (widget.code2 != null) {
                    return FutureBuilder(
                      future: _mailSend2,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            color: Color(0xffecf5f5),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        'img/success.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: Text(
                                              'Vous avez recu un mail descriptif de votre commande et nous vous contacterons lorsque votre commande sera prete... L\'equipe Buy On Send vous remercie et vous donne rendez-vous lors de vos prochains achats',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                              'impossible d\'envoyer le mail recapitulatif');
                        }
                        return Container(
                          color: Color(0xffecf5f5),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'img/success.gif',
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: Text(
                                            'Vous recevrez un mail descriptif de votre commande sous peu...',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Container(
                      color: Color(0xffecf5f5),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'img/success.gif',
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: Text(
                                        'Vous avez recu un mail descriptif de votre commande et nous vous contacterons lorsque votre commande sera prete... L\'equipe Buy On Send vous remercie et vous donne rendez-vous lors de vos prochains achats',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return Text('impossible d\'envoyer le mail recapitulatif');
                }
              }
              return Container(
                color: Color(0xffecf5f5),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'img/success.gif',
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  'Vous recevrez un mail descriptif de votre commande sous peu...',
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
