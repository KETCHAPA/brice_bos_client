import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/model/data.dart';
import 'package:new_bos_app/services/searchService.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SearchBar<Data>(
            minimumChars: 3,
            loader: Center(
              child: Image.asset('img/loading5.gif'),
            ),
            placeHolder: ListView(
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'img/placeholder.jpg',
                  ),
                ),
                SizedBox(
                  height: 6.0,
                ),
                Center(
                    child: Text(
                        'Entrer des mots cles pour effectuer une recherche')),
              ],
            ),
            onError: (_) {
              return ListView(
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  Center(
                    child: Text(
                      '500',
                      style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      'img/error.png',
                    ),
                  ),
                  SizedBox(
                    height: 6.0,
                  ),
                  Center(
                    child: Text("Une erreur est survenue."),
                  ),
                  Center(child: Text('Veuillez rafraichir la page'))
                ],
              );
            },
            emptyWidget: ListView(
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                Center(
                  child: Text(
                    '404',
                    style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'img/empty.jpg',
                  ),
                ),
                SizedBox(
                  height: 6.0,
                ),
                Center(child: Text('Aucune correspondance')),
              ],
            ),
            searchBarPadding: EdgeInsets.symmetric(horizontal: 20.0),
            searchBarStyle: SearchBarStyle(
                backgroundColor: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.all(Radius.circular(60.0)),
                padding: EdgeInsets.symmetric(horizontal: 20.0)),
            icon: Icon(YvanIcons.loupe),
            hintText: 'Recherche...',
            cancellationWidget: Text('Annuler'),
            debounceDuration: Duration(milliseconds: 800),
            onSearch: search,
            onItemFound: (Data data, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => data.redirection));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50.0,
                            height: 50.0,
                            child: ClipOval(
                              child: Image.network(
                                imagePath(data.photo),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    data.title.length > 9
                                        ? '${data.title.substring(0, 9)}... '
                                        : '${data.title} ',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    YvanIcons.arrow_drop_right_line,
                                    size: 14.0,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    ' ${data.parent} ',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  data.details == null
                                      ? SizedBox(
                                          height: 0.0,
                                        )
                                      : Row(
                                          children: <Widget>[
                                            Icon(
                                              YvanIcons.arrow_drop_right_line,
                                              size: 14.0,
                                              color: Colors.black,
                                            ),
                                            Text(
                                              data.details.length > 9
                                                  ? ' ${data.details.substring(0, 9)}...'
                                                  : ' ${data.details}',
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )
                                ],
                              ),
                              data.oldPrice == null
                                  ? SizedBox(
                                      height: 0.0,
                                    )
                                  : Row(
                                      children: <Widget>[
                                        data.description == null ||
                                                data.description == ''
                                            ? SizedBox(
                                                height: 0.0,
                                              )
                                            : Row(
                                                children: <Widget>[
                                                  Text(
                                                    data.description.length > 20
                                                        ? '${data.description.substring(0, 20)}...'
                                                        : data.description,
                                                    style: TextStyle(
                                                        fontSize: 12.0),
                                                  ),
                                                  Icon(
                                                    YvanIcons.arrow_drop_right_line,
                                                    size: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                        data.oldPrice == null ||
                                                data.oldPrice == 0
                                            ? SizedBox(
                                                height: 0.0,
                                              )
                                            : data.newPrice != 0 &&
                                                    data.newPrice != null
                                                ? Text(
                                                    '${data.newPrice} Fcfa',
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black),
                                                  )
                                                : Text(
                                                    '${data.oldPrice} Fcfa',
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black),
                                                  )
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
