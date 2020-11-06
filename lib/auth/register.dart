import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_bos_app/auth/login.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/services/authentication.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sweetalert/sweetalert.dart';

class RegisterPage extends StatefulWidget {
  final Widget redirection;
  RegisterPage({@required this.redirection});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  String _gender = 'Homme';

  Future<File> file, compressFile;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String _town, _country;
  List<String> _countryTowns;
  int currentTownIndex, currentCountryIndex;

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

  ProgressDialog progress;
  void _switchNode(context, FocusNode currentNode, FocusNode nextNode) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextNode);
  }

  @override
  void initState() {
    super.initState();
    progress = loadingWidget(context);
  }

  setPage(int page) {
    if (page == 1) {
      if (_loginController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _cPasswordController.text.isNotEmpty) {
        setPage(1);
      } else {
        sweetalert(
            context: context,
            withConfirmation: false,
            subtitle: 'Remplissez tous les champs',
            type: SweetAlertStyle.confirm);
      }
    } else if (page == 2) {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty) {
        setPage(2);
      } else {
        sweetalert(
            context: context,
            withConfirmation: false,
            subtitle: 'Remplissez tous les champs',
            type: SweetAlertStyle.confirm);
      }
    } else if (page == 3) {
      if (_country != null &&
          _town != null &&
          _addressController.text.isNotEmpty) {
        setPage(3);
      } else {
        sweetalert(
            context: context,
            withConfirmation: false,
            subtitle: 'Remplissez tous les champs',
            type: SweetAlertStyle.confirm);
      }
    }
  }

  String name = '', base64Image = '';

  void _register(BuildContext context) async {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _loginController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _cPasswordController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _country != null &&
        _town != null) {
      Map<String, dynamic> params = Map<String, dynamic>();
      params['name'] = _nameController.text;
      params['email'] = _emailController.text;
      params['login'] = _loginController.text;
      params['phone'] = _phoneController.text;
      params['password'] = _passwordController.text;
      params['c_password'] = _cPasswordController.text;
      params['address'] = _addressController.text;
      params['country'] = _country;
      params['town'] = _town;
      params['street'] = _streetController.text ?? '';
      params['gender'] = _gender;
      if (name.isNotEmpty) {
        params['photo'] = name;
        params['photo_encode'] = base64Image;
      }
      progress.show();

      await register(params).then((success) {
        progress.hide();
        if (success) {
          setState(() {
            isLoggedIn = true;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => widget.redirection));
        } else {
          sweetalert(
              context: context,
              withConfirmation: false,
              title: 'Erreur',
              subtitle: errorMessageText,
              type: SweetAlertStyle.error);
        }
      });
    } else {
      sweetalert(
          context: context,
          withConfirmation: false,
          subtitle: 'Remplissez tous les champs',
          type: SweetAlertStyle.confirm);
    }
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
                    labelStyle: TextStyle(color: Colors.black38),
                    labelText: 'Nom d\'utilisateur'),
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
                    labelStyle: TextStyle(color: Colors.black38),
                    labelText: 'Mot de passe'),
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
                  if (_loginController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty &&
                      _cPasswordController.text.isNotEmpty) {
                    setPage(1);
                  } else {
                    sweetalert(
                        context: context,
                        withConfirmation: false,
                        subtitle: 'Remplissez tous les champs',
                        type: SweetAlertStyle.confirm);
                  }
                },
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    suffixIcon: Icon(
                      YvanIcons.key,
                      color: Colors.black,
                      size: size(context).height / 40.0,
                    ),
                    labelStyle: TextStyle(color: Colors.black38),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusColor: Colors.orange,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    labelText: 'Confirmation'),
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
                        labelStyle: TextStyle(color: Colors.black38),
                        labelText: 'Nom complet'),
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
                        labelStyle: TextStyle(color: Colors.black38),
                        labelText: 'Email'),
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
                      if (_nameController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty &&
                          _phoneController.text.isNotEmpty) {
                        setPage(2);
                      } else {
                        sweetalert(
                            context: context,
                            withConfirmation: false,
                            subtitle: 'Remplissez tous les champs',
                            type: SweetAlertStyle.confirm);
                      }
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        suffixIcon: Icon(
                          YvanIcons.phone_line,
                          color: Colors.black,
                          size: size(context).height / 40.0,
                        ),
                        labelStyle: TextStyle(color: Colors.black38),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusColor: Colors.orange,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Telephone'),
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
                          if (_country != null &&
                              _town != null &&
                              _addressController.text.isNotEmpty) {
                            setPage(3);
                          } else {
                            sweetalert(
                                context: context,
                                withConfirmation: false,
                                subtitle: 'Remplissez tous les champs',
                                type: SweetAlertStyle.confirm);
                          }
                        },
                        decoration: InputDecoration(
                            suffixIcon: Icon(
                              YvanIcons.address,
                              color: Colors.black,
                              size: size(context).height / 40.0,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusColor: Colors.black,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelStyle: TextStyle(color: Colors.black38),
                            labelText: 'Adresse'),
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
                          _register(context);
                        },
                        decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.account_circle,
                              color: Colors.black,
                              size: size(context).height / 40.0,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusColor: Colors.black,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelStyle: TextStyle(color: Colors.black38),
                            labelText: 'Rue (optionnelle)'),
                      ),
                      SizedBox(
                        height: size(context).height / 50.0,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _gender = _gender.toUpperCase() == 'HOMME'
                                ? 'femme'
                                : 'homme';
                          });
                        },
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
                                  '${_gender.toUpperCase()}',
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
                  height: size(context).height / 1.55,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'Bonjour,',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: size(context).height / 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Creer vous un compte',
                        style: TextStyle(
                          color: Colors.black26,
                        ),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      pagination(_currentPage),
                      Spacer(
                        flex: 2,
                      ),
                      RaisedButton(
                        elevation: 0.0,
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size(context).height / 10.0)),
                        onPressed: () => _currentPage < 3
                            ? setPage(++_currentPage)
                            : _register(context),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: size(context).width / 30.0),
                          child: Text(
                            _currentPage > 2
                                ? 'Inscription'
                                : 'Etape ${_currentPage + 1} / 4',
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
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => widget.redirection))
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
                      Spacer(
                        flex: 2,
                      ),
                      Text('Ou inscrivez-vous via les reseaux'),
                      Spacer(
                        flex: 2,
                      ),
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
                      ),
                      Spacer()
                    ],
                  )),
            ),
            SizedBox(height: size(context).height / 15),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(redirection: widget.redirection))),
              child: Center(
                child: RichText(
                    text: TextSpan(
                        text: 'Vous avez un compte ? ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size(context).height / 45.0),
                        children: [
                      TextSpan(
                          text: 'connectez-vous',
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
