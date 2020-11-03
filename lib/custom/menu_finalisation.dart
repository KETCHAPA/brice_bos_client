import 'package:flutter/material.dart';

class FinalisationMenu extends StatefulWidget {
  FinalisationMenu(this.index);
  final int index;

  @override
  _FinalisationMenuState createState() => _FinalisationMenuState();
}

class _FinalisationMenuState extends State<FinalisationMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.grey.withOpacity(.5),
            height: 50.0,
            width: MediaQuery.of(context).size.width / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 21.5,
                  width: 21.5,
                  decoration: BoxDecoration(
                      color: index == widget.index
                          ? Colors.black
                          : Colors.black.withOpacity(.25),
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Center(
                    child: Text(
                      '${menus[index].index}',
                      style: TextStyle(
                          color: index == widget.index
                              ? Colors.white
                              : Colors.white.withOpacity(.65)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  '${menus[index].name}',
                  style: TextStyle(
                      fontSize: 14.0,
                      color: index == widget.index
                          ? Colors.black
                          : Colors.black.withOpacity(.25)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class Menu {
  Menu(this.index, this.name);
  final int index;
  final String name;
}

List<Menu> menus = [
  Menu(
    1,
    'Recapitulatif',
  ),
  Menu(
    2,
    'Paiement',
  ),
  Menu(3, 'Verification')
];
