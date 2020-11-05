import 'package:flutter/material.dart';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/database_management/database2.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/services/authentication.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ProgressDialog progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              YvanIcons.left_arrow_1,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          'Parametres',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
              leading: Icon(
                Icons.language,
                size: size(context).height / 30.0,
              ),
              title: Text('Modifier la langue',
                  style: TextStyle(
                      fontSize: size(context).height / 40.0,
                      color: Colors.black))),
          ListTile(
            leading: Icon(
              YvanIcons.community_line,
              size: size(context).height / 30.0,
            ),
            title: Text('Conditions Generales d\'utilisation de l\'application',
                style: TextStyle(
                    fontSize: size(context).height / 40.0,
                    color: Colors.black)),
            trailing: Text(''),
          ),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => Container(
                        height: 300.0,
                        child: AlertDialog(
                          title: Text('Mode actuel'),
                          content: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text('$modeEndPoint'),
                          ),
                          actions: <Widget>[
                            OutlineButton(
                              child: Text(
                                'Modifier',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChooseDataBase2()));
                              },
                            )
                          ],
                        ),
                      ));
            },
            child: ListTile(
              leading: Icon(
                YvanIcons.edit_2_line,
                size: size(context).height / 30.0,
              ),
              title: Text('consulter le mode d\'utilisation',
                  style: TextStyle(
                      fontSize: size(context).height / 40.0,
                      color: Colors.black)),
              trailing: Text(''),
            ),
          ),
          ListTile(
              leading: Icon(
                YvanIcons.blue_girl_character,
                size: size(context).height / 30.0,
              ),
              title: Text('Nous noter',
                  style: TextStyle(
                      fontSize: size(context).height / 40.0,
                      color: Colors.black))),
          FutureBuilder(
            future: isLogged(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
              if (snapshot.hasData) {
                return snapshot.data == true
                    ? InkWell(
                        onTap: () async {
                          progress = loadingWidget(context);
                          progress.show();
                          await logout().then((success) async {
                            progress.hide();
                            if (success) {
                              setState(() {
                                isLoggedIn = false;
                              });
                              await logOut();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RouterPage(
                                            index: 3,
                                          )));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Erreur de deconnexion'),
                                      content: Text(
                                          'Verifier votre connexion puis reessayer'),
                                      actions: <Widget>[
                                        OutlineButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Okay',
                                              style: TextStyle(
                                                  color: Colors.pink)),
                                        )
                                      ],
                                    );
                                  });
                            }
                          });
                        },
                        child: ListTile(
                            leading: Icon(YvanIcons.logout,
                                size: size(context).height / 30.0,
                                color: Colors.red),
                            title: Text('Deconnexion',
                                style: TextStyle(
                                  fontSize: size(context).height / 40.0,
                                  color: Colors.red,
                                ))),
                      )
                    : SizedBox(
                        height: 0.0,
                      );
              }
              return null;
            },
          )
        ],
      ),
    );
  }
}
