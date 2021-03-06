import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_bos_app/account/recent.dart';
import 'package:new_bos_app/account/update.dart';
import 'package:new_bos_app/addons/mail.dart';
import 'package:new_bos_app/auth/login.dart';
import 'package:new_bos_app/auth/register.dart';
import 'package:new_bos_app/command/all.dart';
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/database_management/database2.dart';
import 'package:new_bos_app/discount/all.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/services/accountService.dart';
import 'package:new_bos_app/services/appService.dart';
import 'package:new_bos_app/services/authentication.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isAccountPage;
  ProgressDialog progress;
  @override
  void initState() {
    super.initState();
    isAccountPage = true;
  }

  Widget firstWidget() {
    return Scaffold(
        body: FutureBuilder(
            future: isLogged(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      'Une erreur est survenue.Veuillez rafraichir la page'),
                );
              }
              if (snapshot.hasData) {
                isLoggedIn = snapshot.data;
                return Padding(
                  padding: EdgeInsets.fromLTRB(size(context).width / 30.0, 0,
                      size(context).width / 30.0, 0),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: size(context).height / 100.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => isAccountPage = false),
                            child: Icon(
                              YvanIcons.settings_line,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, 'cart'),
                            child: Stack(
                              children: [
                                Icon(
                                  YvanIcons.bag,
                                  color: Colors.black,
                                ),
                                Positioned(
                                  right: 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red),
                                    padding: EdgeInsets.all(
                                        size(context).height / 200),
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
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size(context).height / 40.0,
                      ),
                      Container(
                          height: size(context).height / 8.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                !isLoggedIn ? size(context).height / 50 : 0.0),
                            color:
                                !isLoggedIn ? Colors.black : Colors.transparent,
                          ),
                          child: !isLoggedIn
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage(
                                                          redirection:
                                                              RouterPage(
                                                        index: 4,
                                                      ))));
                                        },
                                        child: Text(
                                          'Connexion / ',
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.white),
                                        )),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RegisterPage(
                                                        redirection: RouterPage(
                                                      index: 4,
                                                    ))));
                                      },
                                      child: Text(
                                        'Inscription',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                )
                              : FutureBuilder(
                                  future: getCurrentUser(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.hasError) {
                                      return Center(
                                        child: Text(''),
                                      );
                                    }
                                    if (userSnapshot.hasData) {
                                      userCode = userSnapshot.data['code'];
                                      Map user = userSnapshot.data;
                                      return Row(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width:
                                                    size(context).height / 8.0,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size(context)
                                                                .height),
                                                    child: CachedNetworkImage(
                                                      imageUrl: imagePath(user[
                                                                  'photo'] !=
                                                              null
                                                          ? user['photo']
                                                          : user['gender'] ==
                                                                  'femme'
                                                              ? 'users/avatar2.jpg'
                                                              : 'users/avatar.jpg'),
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              loader(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    )),
                                              ),
                                              Positioned(
                                                right: size(context).height /
                                                    100.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2.0),
                                                      shape: BoxShape.circle,
                                                      color: Colors.green),
                                                  height: size(context).height /
                                                      35.0,
                                                  width: size(context).height /
                                                      35.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size(context).width / 40.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  width:
                                                      size(context).width / 1.6,
                                                  child: Text(
                                                    user['name'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: size(context)
                                                                .height /
                                                            35.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              SizedBox(
                                                height: size(context).height /
                                                    300.0,
                                              ),
                                              Container(
                                                width:
                                                    size(context).width / 1.6,
                                                child: Text(
                                                  "${user['country']} - ${user['town']}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize:
                                                          size(context).height /
                                                              45.0,
                                                      color: Colors.black54),
                                                ),
                                              ),
                                              SizedBox(
                                                height: size(context).height /
                                                    200.0,
                                              ),
                                              Container(
                                                width:
                                                    size(context).width / 1.6,
                                                child: Text(
                                                  user['phone'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize:
                                                          size(context).height /
                                                              55.0,
                                                      color: Colors.black54),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    }
                                    return Center(child: loader());
                                  })),
                      SizedBox(height: size(context).height / 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Commandes',
                            style: TextStyle(
                                color:
                                    !isLoggedIn ? Colors.black45 : Colors.black,
                                fontSize: size(context).height / 40.0,
                                fontWeight: !isLoggedIn
                                    ? FontWeight.normal
                                    : FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: !isLoggedIn
                                ? null
                                : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CommandPage(
                                                  code: userCode,
                                                  title: 'Vos Commandes',
                                                  filter:
                                                      'toutes_vos_commandes',
                                                )));
                                  },
                            child: Icon(
                              YvanIcons.arrow_drop_right_line,
                              color:
                                  !isLoggedIn ? Colors.black45 : Colors.black,
                              size: size(context).height / 40.0,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size(context).height / 70.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: !isLoggedIn
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommandPage(
                                              code: userCode,
                                              title: 'Commandes en attente',
                                              filter: 'en_attente',
                                            ))),
                            child: Column(
                              children: [
                                Icon(
                                  YvanIcons.hourglass,
                                  color: !isLoggedIn
                                      ? Colors.black45
                                      : Colors.black,
                                  size: size(context).height / 30.0,
                                ),
                                SizedBox(height: size(context).height / 100.0),
                                Text(
                                  'En Attente',
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: size(context).height / 55.0),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: !isLoggedIn
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommandPage(
                                              code: userCode,
                                              title: 'Commandes en route',
                                              filter: 'en_route',
                                            ))),
                            child: Column(
                              children: [
                                Icon(
                                  YvanIcons.checkbox_circle_line,
                                  color: !isLoggedIn
                                      ? Colors.black45
                                      : Colors.black,
                                  size: size(context).height / 30.0,
                                ),
                                SizedBox(height: size(context).height / 100.0),
                                Text(
                                  'En Route',
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: size(context).height / 55.0),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: !isLoggedIn
                                ? null
                                : () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Retour et remboursement'),
                                        content: Text(
                                            'Regles de retour et remboursement'),
                                      );
                                    }),
                            child: Column(
                              children: [
                                Icon(
                                  YvanIcons.stopwatch,
                                  color: !isLoggedIn
                                      ? Colors.black45
                                      : Colors.black,
                                  size: size(context).height / 30.0,
                                ),
                                SizedBox(height: size(context).height / 100.0),
                                Text(
                                  'Retour & SAV',
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: size(context).height / 55.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size(context).height / 40.0),
                      Container(
                        height: size(context).height / 15.0,
                        child: Stack(
                          children: [
                            Center(
                              child: Divider(
                                thickness: 2.0,
                              ),
                            ),
                            !isLoggedIn
                                ? Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          child: Card(
                                            elevation: 7.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size(context).height /
                                                            100.0),
                                                color: Colors.black45,
                                              ),
                                              alignment: Alignment.center,
                                              width: size(context).width / 2.5,
                                              height: double.infinity,
                                              child: Text(
                                                'MODIFIER',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        size(context).height /
                                                            42.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size(context).height / 30.0,
                                        ),
                                        GestureDetector(
                                          child: Card(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size(context).height /
                                                          100.0),
                                            ),
                                            elevation: 7.0,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size(context).height /
                                                              100.0),
                                                  color: Colors.white,
                                                ),
                                                alignment: Alignment.center,
                                                width: size(context).width / 7,
                                                child: Icon(
                                                  YvanIcons.message_2_line,
                                                  color: Colors.black45,
                                                  size:
                                                      size(context).height / 35,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : FutureBuilder(
                                    future: getCurrentUser(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasError) {
                                        return Center(
                                          child: Text('Rafraichir la page'),
                                        );
                                      }
                                      if (userSnapshot.hasData) {
                                        return Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UpdateData(
                                                                  user: userSnapshot
                                                                      .data)));
                                                },
                                                child: Card(
                                                  elevation: 7.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size(context)
                                                                      .height /
                                                                  100.0),
                                                      color: Colors.black,
                                                    ),
                                                    alignment: Alignment.center,
                                                    width: size(context).width /
                                                        2.5,
                                                    height: double.infinity,
                                                    child: Text(
                                                      'MODIFIER',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              size(context)
                                                                      .height /
                                                                  42.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    size(context).height / 30.0,
                                              ),
                                              GestureDetector(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewMailPage())),
                                                child: Card(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size(context)
                                                                    .height /
                                                                100.0),
                                                  ),
                                                  elevation: 7.0,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(size(
                                                                        context)
                                                                    .height /
                                                                100.0),
                                                        color: Colors.white,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      width:
                                                          size(context).width /
                                                              7,
                                                      child: Icon(
                                                        YvanIcons
                                                            .message_2_line,
                                                        color: Colors.black,
                                                        size: size(context)
                                                                .height /
                                                            35,
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return Center(child: loader());
                                    }),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: !isLoggedIn
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage(
                                              redirection: widget,
                                            )))
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DiscountPage(code: userCode))),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                YvanIcons.brand,
                                color:
                                    !isLoggedIn ? Colors.black45 : Colors.black,
                                size: size(context).height / 35.0,
                              ),
                              title: Text('Mes coupons',
                                  style: TextStyle(
                                      fontSize: size(context).height / 45.0,
                                      fontWeight: !isLoggedIn
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: !isLoggedIn
                                          ? Colors.black45
                                          : Colors.black)),
                              subtitle: isLoggedIn
                                  ? FutureBuilder(
                                      future: fetchDiscountAmount(userCode),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Text('${snapshot.data} XAF',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    size(context).height / 60.0,
                                              ));
                                        }
                                        return Text('Recuperation...',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  size(context).height / 50.0,
                                            ));
                                      })
                                  : Text('0 XAF',
                                      style: TextStyle(
                                          fontSize: size(context).height / 50.0,
                                          color: Colors.black45)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RouterPage(
                                          index: 2,
                                          canPopFavorite: false,
                                        ))),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                YvanIcons.add_to_favorite,
                                color: Colors.black,
                                size: size(context).height / 35.0,
                              ),
                              title: Text('Boutiques favorites',
                                  style: TextStyle(
                                      fontSize: size(context).height / 45.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          Divider(
                            thickness: 2.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RecentlyProductPage()));
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                YvanIcons.refresh_line,
                                color: Colors.black,
                                size: size(context).height / 35.0,
                              ),
                              title: Text('Vu Recemment',
                                  style: TextStyle(
                                      fontSize: size(context).height / 45.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RouterPage(
                                            index: 2,
                                            isProduct: true,
                                            canPopFavorite: false,
                                          )));
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                YvanIcons.heart,
                                color: Colors.black,
                                size: size(context).height / 35.0,
                              ),
                              title: Text('Liste de souhaits',
                                  style: TextStyle(
                                      fontSize: size(context).height / 45.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          Divider(
                            thickness: 2.0,
                          ),
                          GestureDetector(
                            onTap: () =>
                                launchPhoneCall(phone: '+237699177985'),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.help,
                                  size: size(context).height / 35.0,
                                  color: Colors.black),
                              title: Text('Services Clientele',
                                  style: TextStyle(
                                      fontSize: size(context).height / 45.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => launchWhatsApp(
                                phone: '',
                                message:
                                    'Decouvre Buy, On Send la nouvelle application de vente en ligne de particulier a particulier. play.google.com/store/apps/details?id=com.b2b2c.bosgp'),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                YvanIcons.send_plane_fill,
                                color: Colors.black,
                                size: size(context).height / 35.0,
                              ),
                              title: Text('Inviter un(e) ami(e)',
                                  style: TextStyle(
                                      fontSize: size(context).height / 45.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
              return Center(child: loader());
            }));
  }

  Widget secondWidget() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              YvanIcons.left_arrow_1,
              color: Colors.black,
            ),
            onPressed: () => setState(() => isAccountPage = true)),
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
          GestureDetector(
            onTap: () => launchURL(
                url:
                    'https://play.google.com/store/apps/details?id=com.b2b2c.bosgp'),
            child: ListTile(
                leading: Icon(
                  YvanIcons.blue_girl_character,
                  size: size(context).height / 30.0,
                ),
                title: Text('Nous noter',
                    style: TextStyle(
                        fontSize: size(context).height / 40.0,
                        color: Colors.black))),
          ),
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
                                            index: 4,
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

  @override
  Widget build(BuildContext context) {
    return isAccountPage ? firstWidget() : secondWidget();
  }
}
