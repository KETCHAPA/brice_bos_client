import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/home/router.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/services/authentication.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sweetalert/sweetalert.dart';

class UpdateData extends StatefulWidget {
  final Map user;
  final String secondParameter;
  final List items, quantities;
  final int total;
  final int userId;
  UpdateData(
      {this.user,
      this.secondParameter,
      this.items,
      this.userId,
      this.total,
      this.quantities});
  @override
  _UpdateDataState createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  final _loginController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _emailController = TextEditingController();
  final _cPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();

  int _currentPage = 0;

  final _emailNode = FocusNode();
  final _cPasswordNode = FocusNode();
  final _addressNode = FocusNode();
  final _nameNode = FocusNode();
  final _phoneNode = FocusNode();
  final _passwordNode = FocusNode();
  final _loginNode = new FocusNode();
  final _streetNode = FocusNode();

  ProgressDialog progress;
  void _switchNode(context, FocusNode currentNode, FocusNode nextNode) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextNode);
  }

  Future<File> file, compressFile;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<File> compress(File file) async {
    var dir = await path_provider.getTemporaryDirectory();
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, dir.absolute.path + file.path.split('/').last,
        quality: 50);
    return result;
  }

  getGalleryImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  String _gender;
  String name = '', base64Image = '';

  setPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  String _town, _country;
  List<String> _countryTowns;
  int currentTownIndex, currentCountryIndex;

  @override
  void initState() {
    super.initState();
    _town = widget.user['town'];
    _country = widget.user['country'];
  }

  void _update(BuildContext context) async {
    Map<String, dynamic> params = Map<String, dynamic>();
    params['name'] = _nameController.text ?? widget.user['name'];
    params['email'] = _emailController.text ?? widget.user['email'];
    params['login'] = _loginController.text ?? widget.user['login'];
    params['phone'] = _phoneController.text ?? widget.user['phone'];
    params['password'] = _passwordController.text ?? widget.user['password'];
    params['c_password'] = _cPasswordController.text ?? widget.user['password'];
    params['address'] = _addressController.text ?? widget.user['address'];
    params['country'] = _country ?? widget.user['country'];
    params['town'] = _town ?? widget.user['town'];
    params['street'] = _streetController.text ?? widget.user['street'] ?? '';
    params['gender'] = _gender ?? widget.user['gender'] ?? '';
    if (name.isNotEmpty) {
      params['photo'] = name;
      params['photo_encode'] = base64Image;
    }
    progress = loadingWidget(context);
    progress.show();

    await update(params, widget.user['code']).then((success) {
      progress.hide();
      if (success) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RouterPage(
                      index: 4,
                    )));
      } else {
        sweetalert(
            context: context,
            withConfirmation: false,
            title: 'Erreur',
            subtitle: errorMessageText,
            type: SweetAlertStyle.error);
      }
    });
  }

  Widget pagination(index) {
    return _currentPage == 0
        ? Column(
            children: [
              TextFormField(
                style: TextStyle(color: Colors.black),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (val) {
                  _switchNode(context, _loginNode, _passwordNode);
                },
                focusNode: _loginNode,
                controller: _loginController,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    YvanIcons.account_circle_line,
                    color: Colors.black,
                    size: size(context).height / 40.0,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusColor: Colors.orange,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: '${widget.user['login'] ?? 'Non renseigne'}',
                ),
              ),
              SizedBox(
                height: size(context).height / 50.0,
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                textInputAction: TextInputAction.next,
                controller: _passwordController,
                focusNode: _passwordNode,
                onFieldSubmitted: (val) {
                  _switchNode(context, _passwordNode, _cPasswordNode);
                },
                obscureText: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    YvanIcons.key,
                    color: Colors.black,
                    size: size(context).height / 40.0,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusColor: Colors.orange,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: '**********',
                ),
              ),
              SizedBox(
                height: size(context).height / 50.0,
              ),
              TextFormField(
                obscureText: true,
                controller: _cPasswordController,
                focusNode: _cPasswordNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (val) {
                  _cPasswordNode.unfocus();
                },
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    YvanIcons.key,
                    color: Colors.black,
                    size: size(context).height / 40.0,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusColor: Colors.orange,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: '**********',
                ),
              ),
            ],
          )
        : _currentPage == 1
            ? Column(
                children: [
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    focusNode: _nameNode,
                    keyboardType: TextInputType.text,
                    onFieldSubmitted: (val) {
                      _switchNode(context, _nameNode, _emailNode);
                    },
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        YvanIcons.user_6_line,
                        color: Colors.black,
                        size: size(context).height / 40.0,
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      focusColor: Colors.orange,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: '${widget.user['name'] ?? 'Non renseigne'}',
                    ),
                  ),
                  SizedBox(
                    height: size(context).height / 50.0,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailNode,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (val) {
                      _switchNode(context, _emailNode, _phoneNode);
                    },
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        YvanIcons.email,
                        color: Colors.black,
                        size: size(context).height / 40.0,
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      focusColor: Colors.orange,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: '${widget.user['email'] ?? 'Non renseigne'}',
                    ),
                  ),
                  SizedBox(
                    height: size(context).height / 50.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: _phoneController,
                    focusNode: _phoneNode,
                    onFieldSubmitted: (val) {
                      _phoneNode.unfocus();
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        YvanIcons.phone_line,
                        color: Colors.black,
                        size: size(context).height / 40.0,
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      focusColor: Colors.orange,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: '${widget.user['phone'] ?? 'Non renseigne'}',
                    ),
                  ),
                ],
              )
            : _currentPage == 2
                ? Column(
                    children: [
                      InkWell(
                        onTap: () =>
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor: Colors.white,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(
                                      size(context).height / 100.0))),
                          action: SnackBarAction(
                            textColor: Colors.redAccent,
                            label: 'Fermer',
                            onPressed: () =>
                                _scaffoldKey.currentState.hideCurrentSnackBar(),
                          ),
                          duration: new Duration(minutes: 1),
                          content: Container(
                            height: 30.0 * countries.length >
                                    MediaQuery.of(context).size.height / 3
                                ? MediaQuery.of(context).size.height / 3
                                : 30.0 * countries.length,
                            child: ListView.builder(
                              itemBuilder: (context, int index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _country = countries[index].country;
                                      _countryTowns = countries[index].town;
                                      currentCountryIndex = index;
                                    });
                                    _scaffoldKey.currentState
                                        .hideCurrentSnackBar();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2.5),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          index == currentCountryIndex
                                              ? Icons.check_circle_outline
                                              : Icons.brightness_1,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          countries[index].country,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight:
                                                  index == currentCountryIndex
                                                      ? FontWeight.bold
                                                      : FontWeight.normal),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: countries.length,
                            ),
                          ),
                        )),
                        child: Container(
                            width: MediaQuery.of(context).size.width * .9,
                            height: 50.0,
                            padding: EdgeInsets.symmetric(
                                horizontal: size(context).width / 30.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  size(context).height / 150.0),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${_country ?? 'Pays'}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  YvanIcons.arrow_drop_down_line,
                                  color: Colors.black.withOpacity(.8),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: size(context).height / 50.0,
                      ),
                      InkWell(
                        onTap: () => _countryTowns == null
                            ? null
                            : _scaffoldKey.currentState.showSnackBar(SnackBar(
                                backgroundColor: Colors.white,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            size(context).height / 100.0))),
                                action: SnackBarAction(
                                  textColor: Colors.redAccent,
                                  label: 'Fermer',
                                  onPressed: () => _scaffoldKey.currentState
                                      .hideCurrentSnackBar(),
                                ),
                                duration: new Duration(minutes: 1),
                                content: Container(
                                  height: 30.0 * _countryTowns.length >
                                          MediaQuery.of(context).size.height / 3
                                      ? MediaQuery.of(context).size.height / 3
                                      : 30.0 * _countryTowns.length,
                                  child: ListView.builder(
                                    itemBuilder: (context, int index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _town = _countryTowns[index];

                                            currentTownIndex = index;
                                          });
                                          _scaffoldKey.currentState
                                              .hideCurrentSnackBar();
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.5),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                index == currentTownIndex
                                                    ? Icons.check_circle_outline
                                                    : Icons.brightness_1,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                _countryTowns[index],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: index ==
                                                            currentTownIndex
                                                        ? FontWeight.bold
                                                        : FontWeight.normal),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: _countryTowns.length,
                                  ),
                                ),
                              )),
                        child: Container(
                            width: MediaQuery.of(context).size.width * .9,
                            height: 50.0,
                            padding: EdgeInsets.symmetric(
                                horizontal: size(context).width / 30.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  size(context).height / 150.0),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _town ?? 'Ville',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  YvanIcons.arrow_drop_down_line,
                                  color: Colors.black.withOpacity(.8),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: size(context).height / 50.0,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        controller: _addressController,
                        textInputAction: TextInputAction.done,
                        focusNode: _addressNode,
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (val) {
                          _addressNode.unfocus();
                        },
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            YvanIcons.address,
                            color: Colors.black,
                            size: size(context).height / 40.0,
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusColor: Colors.orange,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText:
                              '${widget.user['address'] ?? 'Non renseigne'}',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        controller: _streetController,
                        focusNode: _streetNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (val) {
                          _streetNode.unfocus();
                        },
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            YvanIcons.address,
                            color: Colors.black,
                            size: size(context).height / 40.0,
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusColor: Colors.orange,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText:
                              '${widget.user['street'] ?? 'Non renseigne'}',
                        ),
                      ),
                      SizedBox(
                        height: size(context).height / 50.0,
                      ),
                      InkWell(
                        onTap: () {
                          if (_gender == null) {
                            if (widget.user['gender'] == null) {
                              setState(() {
                                _gender = 'homme';
                              });
                            } else {
                              setState(() {
                                _gender = widget.user['gender'].toUpperCase() ==
                                        'HOMME'
                                    ? 'femme'
                                    : 'homme';
                              });
                            }
                          } else {
                            setState(() {
                              _gender = _gender.toUpperCase() == 'HOMME'
                                  ? 'femme'
                                  : 'homme';
                            });
                          }
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width * .9,
                            height: 50.0,
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${(_gender ?? widget.user['gender'] ?? 'Non Renseigne').toUpperCase()}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  YvanIcons.gender,
                                  color: Colors.black.withOpacity(.8),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: size(context).height / 50.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Profil'),
                          SizedBox(
                            width: 10.0,
                          ),
                          InkWell(
                            onTap: getGalleryImage,
                            child: Container(
                              width: 55.0,
                              height: 55.0,
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: ClipOval(
                                        child: FutureBuilder(
                                            future: file,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<File> snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  null != snapshot.data) {
                                                return FutureBuilder(
                                                  future:
                                                      compress(snapshot.data),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<File>
                                                              snapshot) {
                                                    if (snapshot.connectionState ==
                                                            ConnectionState
                                                                .done &&
                                                        null != snapshot.data) {
                                                      name =
                                                          '${snapshot.data.path.split('/').last}';
                                                      base64Image =
                                                          '${base64Encode(snapshot.data.readAsBytesSync())}';
                                                      return Image.file(
                                                        snapshot.data,
                                                        fit: BoxFit.fill,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .5,
                                                      );
                                                    } else if (null !=
                                                        snapshot.error) {
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: Text(
                                                            'Erreur de compression de l\'image'),
                                                      ));
                                                      return Container();
                                                    } else {
                                                      return Container();
                                                    }
                                                  },
                                                );
                                              }
                                              if (null != snapshot.error) {
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Erreur de recuperation de l\'image'),
                                                ));
                                              }
                                              return Image.network(
                                                imagePath('users/avatar.jpg'),
                                                fit: BoxFit.fill,
                                              );
                                            })),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Icon(
                                          YvanIcons.edit_2_line,
                                          size: 15.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Container(
                height: size(context).height / 6,
                alignment: Alignment.center,
                child: Container(
                    child: Text(
                  'BUY, ON SEND',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: size(context).height / 30.0,
                      fontWeight: FontWeight.bold),
                ))),
            Card(
              elevation: 100.0,
              color: Colors.transparent,
              child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: size(context).width / 18.0),
                  padding: EdgeInsets.symmetric(
                      horizontal: size(context).width / 28.0,
                      vertical: size(context).width / 28.0),
                  height: size(context).height / 1.6,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'Mise a jour,',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: size(context).height / 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Mettez vos informations a jour',
                        style: TextStyle(
                          color: Colors.black26,
                        ),
                      ),
                      Spacer(),
                      pagination(_currentPage),
                      Spacer(),
                      RaisedButton(
                        elevation: 0.0,
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size(context).height / 10.0)),
                        onPressed: () => _currentPage < 3
                            ? setPage(++_currentPage)
                            : _update(context),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: size(context).width / 30.0),
                          child: Text(
                            _currentPage > 2 ? 'Mise a jour' : 'Suivant',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      RaisedButton(
                        elevation: 0.0,
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size(context).height / 10.0)),
                        onPressed: () => _currentPage == 0
                            ? Navigator.pop(context)
                            : setPage(--_currentPage),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: size(context).width / 30.0),
                          child: Text(
                            'Retour',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Text('Ou inscrivez-vous via les reseaux'),
                      Spacer(),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: size(context).height / 10.0,
                        ),
                        height: size(context).height / 30.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'img/fb.png',
                              fit: BoxFit.fill,
                            ),
                            Image.asset(
                              'img/twitter.png',
                              fit: BoxFit.fill,
                            ),
                            Image.asset(
                              'img/google.png',
                              fit: BoxFit.fill,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            SizedBox(height: size(context).height / 15),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RouterPage(
                            index: 4,
                          ))),
              child: Center(
                child: RichText(
                    text: TextSpan(
                        text: 'revenir sur ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size(context).height / 45.0),
                        children: [
                      TextSpan(
                          text: 'mon compte',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xff10ae9f)))
                    ])),
              ),
            )
          ],
        ));
  }
}
