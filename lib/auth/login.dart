import 'package:flutter/material.dart';
import 'package:new_bos_app/auth/register.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/custom/sweetAlert.dart';
import 'package:new_bos_app/icons/yvan_icons.dart';
import 'package:new_bos_app/services/authentication.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sweetalert/sweetalert.dart';

class LoginPage extends StatefulWidget {
  final Widget redirection;
  LoginPage({@required this.redirection});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode _passwordNode, _loginNode;
  TextEditingController _passwordController, _loginController;
  bool _obscureText;

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordController = new TextEditingController();
    _loginController = new TextEditingController();
    _passwordNode = new FocusNode();
    _loginNode = new FocusNode();
    _obscureText = true;
  }

  ProgressDialog progress;

  submit(BuildContext context, progress) async {
    if (_loginController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      Map<String, dynamic> params = Map<String, dynamic>();
      print('${_loginController.text} ${_passwordController.text}');
      params['login'] = _loginController.text;
      params['password'] = _passwordController.text;
      progress = loadingWidget(context);
      progress.show();
      await login(params).then((success) {
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
        subtitle: 'Remplissez tous les champs',
        withConfirmation: false,
        type: SweetAlertStyle.confirm,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, //Color(0xffeeeeee),
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
                        'Bonjour,',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: size(context).height / 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Connectez-vous a votre compte',
                        style: TextStyle(
                          color: Colors.black26,
                        ),
                      ),
                      Spacer(),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        controller: _loginController,
                        focusNode: _loginNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          setState(() {
                            _loginNode.unfocus();
                            FocusScope.of(context).requestFocus(_passwordNode);
                          });
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
                            labelText: 'Nom d\'utilisateur'),
                      ),
                      SizedBox(
                        height: size(context).height / 50.0,
                      ),
                      TextFormField(
                        obscureText: _obscureText,
                        style: TextStyle(color: Colors.black),
                        controller: _passwordController,
                        focusNode: _passwordNode,
                        onFieldSubmitted: (value) {
                          setState(() {
                            _passwordNode.unfocus();
                          });
                        },
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: toggle,
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                                size: size(context).height / 40.0,
                              ),
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelStyle: TextStyle(color: Colors.black38),
                            focusColor: Colors.black,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: 'Mot de passe'),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: size(context).height / 100.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Mot de passe oublie ?',
                            style: TextStyle(color: Colors.black26),
                          ),
                        ),
                      ),
                      Spacer(),
                      RaisedButton(
                        elevation: 0.0,
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size(context).height / 10.0)),
                        onPressed: () => submit(context, progress),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: size(context).width / 30.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Connexion',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Spacer(),
                      Text('Ou connectez-vous via les reseaux'),
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
                          RegisterPage(redirection: widget.redirection))),
              child: Center(
                child: RichText(
                    text: TextSpan(
                        text: 'Pas encore de compte ? ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size(context).height / 45.0),
                        children: [
                      TextSpan(
                          text: 'creez-en un',
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
