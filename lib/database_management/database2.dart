import 'package:flutter/material.dart';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart';

class ChooseDataBase2 extends StatefulWidget {
  ChooseDataBase2();
  @override
  _ChooseDataBase2State createState() => _ChooseDataBase2State();
}

class _ChooseDataBase2State extends State<ChooseDataBase2> {
  int isSelected;
  String mode, url, _image;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < items.length; i++) {
      if (items[i].text == modeEndPoint) {
        setState(() {
          isSelected = i;
        });
      }
    }
    logOutUser();
  }

  logOutUser() async {
    token = '';
    await logOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                      await setDatabaseUrl(url, mode, _image);
                      modeEndPoint = mode;
                      endPoint = url;
                      imageEndPoint = _image;
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                ),
              ],
            ),
          ),
          body: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 4.0),
                    child: Text('Mode avec lequel vous allez'),
                  ),
                  Text('continuer'),
                  Spacer(),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 140,
                          child: ListView.builder(
                            physics: ScrollPhysics(parent: null),
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    isSelected = index;
                                    mode = items[index].text;
                                    url = items[index].url;
                                    _image = items[index].image;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        index == isSelected
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: index == isSelected
                                            ? Colors.deepOrangeAccent
                                            : Colors.black.withOpacity(.1),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        items[index].text,
                                        style: TextStyle(fontSize: 15.0),
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
                  ),
                  Spacer()
                ],
              ))),
    );
  }
}

class Item {
  final String text;
  final String url;
  final String image;
  Item({this.text, this.url, this.image});
}

List<Item> items = [
  Item(
      text: 'Mode developpeur',
      url: 'https://apiecommerce.bdconsulting-cm.com/api',
      image: 'apiecommerce'),
  Item(
      text: 'Mode test',
      url: 'https://apiecommerceproduction.bdconsulting-cm.com/api',
      image: 'apiecommerceproduction'),
];
