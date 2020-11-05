import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/categories.dart';
import 'package:new_bos_app/model/products.dart';
import 'package:new_bos_app/services/appService.dart';
import 'package:new_bos_app/services/productService.dart';
import 'package:sweetalert/sweetalert.dart';

class ShowProduct extends StatefulWidget {
  final String code;
  final String urlImage;

  const ShowProduct({Key key, this.code, this.urlImage}) : super(key: key);
  @override
  _ShowProductState createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  Future<Map> productSpecs;
  Product product;
  List<Category> categories = [];
  List categoryMap = [], pics = [];
  int nbrPics = 0;
  Future _reviews;
  List _colors, _sizes;
  int _colorIndex, _sizeIndex;

  String format(String date) {
    DateTime data = DateTime.parse(date);
    return '${data.day} ${months[data.month - 1]} ${data.year}';
  }

  String estimateDate() {
    DateTime now = DateTime.now();
    DateTime firstDate, secondDate;
    firstDate = now.add(Duration(hours: 48));
    secondDate = now.add(Duration(hours: 144));

    return '${firstDate.day} ${months[firstDate.month - 1]} - ${secondDate.day} ${months[secondDate.month - 1]}';
  }

  @override
  void initState() {
    super.initState();
    productSpecs = fetchProduct(widget.code);
    _reviews = fetchAllReviews(widget.code);
    _colors = [Colors.grey, Colors.grey[100], Colors.brown, Colors.orange];
    _sizes = ['S', 'M', 'L'];
    _sizeIndex = 0;
    _colorIndex = 0;
  }

  int _selectedItem = 0;
  Widget _pageSelectedIndex(int length) {
    return Container(
      height: 20.0,
      width: length * 9.0,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: ScrollPhysics(parent: null),
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          return Icon(
            Icons.brightness_1,
            size: 7.0,
            color: index == _selectedItem ? Colors.black : Colors.blueGrey,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: productSpecs,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: Text(
                'Une erreur est survenue. Veuillez rafraichir la page',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          product = Product.fromJson(snapshot.data['produit']);
          categoryMap = snapshot.data['categories'];
          categories =
              categoryMap.map((cat) => Category.fromJson(cat)).toList();
          pics = snapshot.data['photos']['pics'];
          nbrPics = snapshot.data['photos']['count'];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.only(top: size(context).height / 30),
                      child: Icon(
                        YvanIcons.left_arrow_1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                floating: true,
                pinned: false,
                primary: false,
                expandedHeight: size(context).height / 1.8,
                flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {
                        _selectedItem = index;
                      });
                    },
                    itemCount: nbrPics,
                    itemBuilder: (BuildContext context, index) {
                      return CachedNetworkImage(
                        imageUrl: imagePath('${pics[index]}'),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => loader(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      );
                    },
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize:
                      Size(size(context).width, size(context).height / 50.0),
                  child: _pageSelectedIndex(nbrPics),
                ),
                actions: [
                  IconButton(
                      padding: EdgeInsets.only(top: size(context).height / 30),
                      icon: Stack(
                        children: [
                          Icon(
                            YvanIcons.bag,
                            color: Colors.black,
                          ),
                          Positioned(
                            right: 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                              padding:
                                  EdgeInsets.all(size(context).height / 200),
                              child: Text(
                                length.toString(),
                                style: TextStyle(
                                    fontSize: size(context).height / 70.0,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                      onPressed: () => Navigator.pushNamed(context, 'cart')),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (favoriteDescriptions
                                  .contains(product.description) &&
                              favoriteNames.contains(product.name)) {
                            favorites.remove(product);
                            favoriteDescriptions.remove(product.description);
                            favoriteNames.remove(product.name);
                          } else {
                            favorites.add(product);
                            favoriteNames.add(product.name);
                            favoriteDescriptions.add(product.description);
                          }
                          storeFavorite(favorites);
                        });
                      },
                      padding: EdgeInsets.only(top: size(context).height / 30),
                      icon: Icon(
                        favoriteNames.contains(product.name) &&
                                favoriteDescriptions
                                    .contains(product.description)
                            ? Icons.favorite
                            : YvanIcons.heart,
                        color: favoriteNames.contains(product.name) &&
                                favoriteDescriptions
                                    .contains(product.description)
                            ? Colors.red[500]
                            : Colors.black87,
                      )),
                ],
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(size(context).height / 10.0))),
                  margin: EdgeInsets.symmetric(
                      vertical: size(context).height / 45.0,
                      horizontal: size(context).height / 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size(context).height / 40.0)),
                          Text(
                              'XAF ${product.newPrice != 0 && product.newPrice != null ? product.newPrice : product.oldPrice}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size(context).height / 50.0))
                        ],
                      ),
                      SizedBox(height: size(context).height / 100.0),
                      Text(product.description),
                      SizedBox(height: size(context).height / 40.0),
                      Text('Couleur'),
                      SizedBox(height: size(context).height / 100.0),
                      Container(
                        height: size(context).height / 25,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _colorIndex = index;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: size(context).height / 100.0),
                                  padding: EdgeInsets.all(
                                      size(context).height / 50.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _colors[index]),
                                ),
                                index != _colorIndex
                                    ? Container()
                                    : Positioned(
                                        right: 0,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right:
                                                  size(context).height / 100.0),
                                          padding: EdgeInsets.all(
                                              size(context).height / 150.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.0),
                                              shape: BoxShape.circle,
                                              color: Colors.purpleAccent),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          itemCount: _colors.length,
                        ),
                      ),
                      SizedBox(height: size(context).height / 40.0),
                      Text('Taille'),
                      SizedBox(height: size(context).height / 100.0),
                      Container(
                        height: size(context).height / 20,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _sizeIndex = index;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  EdgeInsets.all(size(context).height / 70.0),
                              margin: EdgeInsets.only(
                                  right: size(context).height / 100.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _sizeIndex
                                      ? Colors.black
                                      : Colors.grey[100]),
                              child: Text(
                                _sizes[index],
                                style: TextStyle(
                                    color: index == _sizeIndex
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          itemCount: _sizes.length,
                        ),
                      ),
                      SizedBox(height: size(context).height / 40.0),
                      Text('Metadonnees'),
                      SizedBox(height: size(context).height / 100.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size(context).width / 2.6,
                            child: Text(
                              'Boutique: ${product.shopName ?? 'Non renseigne'}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: size(context).width / 4,
                            child: Text(
                              'Disponible: ${product.available}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Container(
                            width: size(context).width / 7,
                            child: Text(
                              'Note: ${product.rate}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder(
                          future: _reviews,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Center(
                                  child: Text(
                                    'Impossible de charger les avis pour le moment',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              List data = [];
                              double rate = 0.0;
                              int rateInt = 0;
                              for (var item in snapshot.data) {
                                if (!data.contains(item)) {
                                  rate += double.parse(item['note']);
                                  data.add(item);
                                }
                              }
                              rate /= data.isNotEmpty ? data.length : 1;
                              rateInt = rate.toInt();
                              return data.isEmpty
                                  ? SizedBox(
                                      height: 0.0,
                                    )
                                  : Column(
                                      children: <Widget>[
                                        SizedBox(
                                            height:
                                                size(context).height / 40.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Avis (${data.length})',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              Spacer(),
                                              Text(
                                                'Tout voir',
                                                style:
                                                    TextStyle(fontSize: 13.0),
                                              ),
                                              Icon(
                                                YvanIcons.arrow_drop_right_line,
                                                size: 10.0,
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                rate.toString().length > 3
                                                    ? '${rate.toString().substring(0, 3)}'
                                                    : rate.toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              renderStars(rateInt)
                                            ],
                                          ),
                                        ),
                                        Container(
                                            height: 81,
                                            child: PageView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: data.length,
                                                itemBuilder:
                                                    (context, int index) {
                                                  return Column(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: 71.0,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 40.0,
                                                                width: 40.0,
                                                                child: ClipOval(
                                                                    child: Image.network(imagePath(data[index]['client']['photo'] ??
                                                                            data[index]['client']['gender'] ==
                                                                                'femme'
                                                                        ? 'users/avatar2.jpg'
                                                                        : 'users/avatar.jpg'))),
                                                              ),
                                                              SizedBox(
                                                                width: 20.0,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      '${data[index]['client']['name']}'),
                                                                  Text(
                                                                      '${format(data[index]['date'])}'),
                                                                  Text(data[index]['message']
                                                                              .length >
                                                                          20
                                                                      ? '${data[index]['message'].substring(0, 20)}...'
                                                                      : data[index]
                                                                          [
                                                                          'message']),
                                                                ],
                                                              ),
                                                              Spacer(),
                                                              Column(
                                                                children: <
                                                                    Widget>[
                                                                  Spacer(),
                                                                  renderStars(int
                                                                      .parse(data[
                                                                              index]
                                                                          [
                                                                          'note'])),
                                                                  Spacer()
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }))
                                      ],
                                    );
                            }

                            return loader();
                          }),
                      SizedBox(height: size(context).height / 40.0),
                      Row(
                        children: <Widget>[
                          Text(
                            'Date estimee de livraison:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Spacer(),
                          Text(
                            '${estimateDate()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: size(context).height / 40.0),
                      Row(
                        children: [
                          Expanded(
                            child: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  if (canAddProduct(product)) {
                                    if (cartDescription.contains(product
                                            .description
                                            .toLowerCase()) &&
                                        cartNames.contains(
                                            product.name.toLowerCase())) {
                                      quantities[cartNames.lastIndexOf(
                                          product.name.toLowerCase())]++;
                                      setCartQuantities(quantities);
                                      evaluateTotal(product.newPrice == 0 ||
                                              product.newPrice == null
                                          ? product.oldPrice
                                          : product.newPrice);
                                    } else {
                                      cartNames.add(product.name.toLowerCase());
                                      cartDescription.add(
                                          product.description.toLowerCase());
                                      carts.add(product);
                                      storeProductCart(carts);
                                      quantities.add(1);
                                      setCartQuantities(quantities);
                                      length = carts.length;
                                      setCartLength(length);
                                      evaluateTotal(product.newPrice == 0 ||
                                              product.newPrice == null
                                          ? product.oldPrice
                                          : product.newPrice);
                                      commandShopIds.add(product.shopId);
                                      shopNames.add(product.shopName);
                                      setNumberOfShopInCommand();
                                    }
                                    new Future.delayed(new Duration(seconds: 2),
                                        () {
                                      SweetAlert.show(context,
                                          subtitle: 'Produit ajoute au panier',
                                          style: SweetAlertStyle.success);
                                    });
                                  } else {
                                    new Future.delayed(new Duration(seconds: 2),
                                        () {
                                      SweetAlert.show(context,
                                          subtitle:
                                              'Vous ne pouvez pas commander\n        dans plus de 2 boutiques',
                                          style: SweetAlertStyle.confirm);
                                    });
                                  }
                                  SweetAlert.show(context,
                                      title: 'Un instant...',
                                      subtitle: 'Ajout du produit au panier',
                                      style: SweetAlertStyle.loading);
                                });
                              },
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 50.0)),
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    vertical: size(context).height / 40.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      YvanIcons.bag,
                                      color: Colors.white,
                                      size: size(context).height / 35.0,
                                    ),
                                    SizedBox(
                                      width: size(context).width / 45.0,
                                    ),
                                    Text(
                                      'ajouter au panier',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              size(context).height / 45.0),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size(context).width / 40.0,
                          ),
                          GestureDetector(
                            onTap: () => launchWhatsApp(
                                phone: snapshot.data['produit']['admin_phone'],
                                message:
                                    "Bonjour M./Mme. ${snapshot.data['produit']['admin_name']}. J'aimerais echanger avec vous concernant le produit ${product.name}. Ma question est"),
                            child: Card(
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    size(context).height / 50.0),
                              ),
                              child: Container(
                                width: size(context).width / 5,
                                height: size(context).height / 13.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size(context).height / 50.0),
                                  child: Image.asset('img/whatsapp.png',
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ]))
            ],
          );
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black12,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.only(top: size(context).height / 30),
                    child: Icon(
                      YvanIcons.left_arrow_1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              floating: true,
              pinned: false,
              primary: false,
              expandedHeight: size(context).height / 1.8,
              flexibleSpace: loader(),
              actions: [
                IconButton(
                    padding: EdgeInsets.only(top: size(context).height / 30),
                    icon: Stack(
                      children: [
                        Icon(
                          YvanIcons.bag,
                          color: Colors.black,
                        ),
                        Positioned(
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            padding: EdgeInsets.all(size(context).height / 200),
                            child: Text(
                              length.toString(),
                              style: TextStyle(
                                  fontSize: size(context).height / 70.0,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    onPressed: () => Navigator.pushNamed(context, 'cart')),
                IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.only(top: size(context).height / 30),
                    icon: Icon(
                      YvanIcons.heart,
                      color: Colors.black87,
                    )),
              ],
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Center(
                child: loader(),
              )
            ]))
          ],
        );
      },
    ));
  }
}
