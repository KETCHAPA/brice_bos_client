import 'package:flutter/material.dart';
import 'package:new_bos_app/auth/register.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/home/home.dart';

class ChoicePage extends StatefulWidget {
  @override
  _ChoicePageState createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('img/start1.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black38, Colors.black54, Colors.black87])),
          ),
          Column(
            children: [
              Spacer(
                flex: 2,
              ),
              Hero(
                tag: 'title',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BUY, ON SEND',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: size(context).height / 25,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Bienvenue,',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: size(context).height / 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Spacer(
                flex: 6,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: size(context).width / 10),
                child: RaisedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage(redirection: HomePage()))),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(size(context).height / 50.0)),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                        vertical: size(context).height / 40.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CREER UN COMPTE',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size(context).height / 45.0),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size(context).height / 50.0,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: size(context).width / 10),
                child: RaisedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage(redirection: HomePage()))),
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(size(context).height / 50.0)),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                        vertical: size(context).height / 40.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SE CONNECTER',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: size(context).height / 45.0),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, 'home'),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: size(context).height / 100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Ignorer',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(Icons.arrow_right, color: Colors.white)
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
