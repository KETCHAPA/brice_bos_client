import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/auth/login.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/orders/checkout_new.dart';
import 'package:sweetalert/sweetalert.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void changeQuantity(int price, String sign) {
    setState(() {
      setTotal(price, sign);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CheckOutNew(
                                                                userId:
                                                                    userSnapshot
                                                                            .data[
                                                                        'id'],
                                                                items: carts,
                                                                total: total,
                                                                quantities:
                                                                    quantities))));
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
}
