import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dialog_controller.dart';
import 'mobile_config.dart';
import 'phone_checked_repository.dart';
import '../../generated/l10n.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class MobileVerification extends StatelessWidget {

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  get child => null;

  Future<bool> loginUser(String phone, BuildContext context) async{

    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{

          removePhone();
          UserCredential result = await _auth.signInWithCredential(credential);
          User user = result.user;

          if(user != null){

            setPhoneChecked(phone);
            VerificationCompletedDialog(context, S.of(context).kriacoes_mobile_phone_confirmed_header, S.of(context).kriacoes_mobile_phone_signup_step, S.of(context).kriacoes_mobile_btn_signup);

          }
        },

        verificationFailed: (FirebaseAuthException authException){
          print(authException.message);

          if (authException.message.contains('not authorized'))
            errorDialog(context, S.of(context).kriacoes_mobile_not_authorized_title, S.of(context).kriacoes_mobile_not_authorized_msg);

          else if (authException.message.contains('Network'))
            errorDialog(context, S.of(context).kriacoes_mobile_network_title, S.of(context).kriacoes_mobile_network_msg);

          else if (authException.message.contains('[ Invalid format. ]'))
            errorDialog(context, S.of(context).kriacoes_mobile_invalid_format_title, S.of(context).kriacoes_mobile_invalid_format_msg);

          else if (authException.message.contains('[ TOO_SHORT ]'))
            errorDialog(context, S.of(context).kriacoes_mobile_too_short_title, S.of(context).kriacoes_mobile_too_short_msg);

          else if (authException.message.contains('[ TOO_LONG ]'))
            errorDialog(context, S.of(context).kriacoes_mobile_too_long_title, S.of(context).kriacoes_mobile_too_long_title);

          else if (authException.message.contains('We have blocked'))
            errorDialog(context, S.of(context).kriacoes_mobile_we_have_blocked_title, S.of(context).kriacoes_mobile_we_have_blocked_msg );

          else
          errorDialog(context, S.of(context).kriacoes_mobile_generic_title, S.of(context).kriacoes_mobile_generic_msg + authException.message);
        },

        codeSent: (String verificationId, [int forceResendingToken]){

          showToast(S.of(context).kriacoes_mobile_sms_send_code + " " + phone, Theme.of(context).accentColor);

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {

                return AlertDialog(
                  title: Text(S.of(context).kriacoes_mobile_give_the_code),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 15),
                      TextFormField(
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // ignore: deprecated_member_use
                          WhitelistingTextInputFormatter.digitsOnly
                        ], 
                        controller: _codeController,
                         decoration: InputDecoration(
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: "0 0 0 0 0 0",
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.phonelink_lock, color: Theme.of(context).accentColor),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            color: Theme.of(context).accentColor,
                            icon: Icon(Icons.sms),
                          ),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),

                    ],
                  ),
                  actions: <Widget>[
                    SizedBox(height: 15),
                    BlockButtonWidget(
                      text: Text(
                        S.of(context).kriacoes_mobile_btn_check,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: () async{
                        if (_codeController.text.length == 6) {
                          try {
                            final code = _codeController.text.trim();
                            AuthCredential credential = PhoneAuthProvider
                                .credential(
                                verificationId: verificationId, smsCode: code);
                            UserCredential result = await _auth
                                .signInWithCredential(credential);
                            User user = result.user;
                            if (user != null) {
                              setPhoneChecked(phone);
                              VerificationCompletedDialog(context, S.of(context).kriacoes_mobile_phone_confirmed_header, S.of(context).kriacoes_mobile_phone_signup_step, S.of(context).kriacoes_mobile_btn_signup);
                            }
                          }
                          catch (e) {
                            if (e.toString().contains('credential is invalid.') != null) {
                              showToast(S.of(context).kriacoes_mobile_error_invalid_verification_code, Colors.red);
                            }else{
                              showToast(e.toString(), Colors.red);
                            }
                          }
                        }if (_codeController.text.length == 0){
                          showToast(S.of(context).kriacoes_mobile_empty_code, Colors.red);
                        }else{
                          showToast(S.of(context).kriacoes_mobile_wrong_size_code, Colors.red);
                        }
                      },
                    ),
                  ],
                );
              }
          );
        }, codeAutoRetrievalTimeout: (String verificationId) {
      showToast("The code has expired please try again ...", Colors.red);
    },
    );
  }
  void initState() {
    removePhone();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 150,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  S.of(context).kriacoes_mobile_header,
                  style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 100,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  S.of(context).kriacoes_mobile_sub_header,
                  style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                  BoxShadow(
                    blurRadius: 50,
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                  )
                ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
                width: config.App(context).appWidth(88),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _phoneController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: S.of(context).kriacoes_mobile_phone,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: S.of(context).kriacoes_mobile_hint,
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixText: MobileConfig.default_ddi + " ",
                          prefixIcon: Icon(Icons.mobile_screen_share, color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),

                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context).kriacoes_mobile_send_code,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          final phone = MobileConfig.default_ddi + _phoneController.text.trim();
                          loginUser(phone, context);
                        },

                      ),
                      SizedBox(height: 15),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                        },
                        shape: StadiumBorder(),
                        textColor: Theme.of(context).hintColor,
                        child: Text(S.of(context).skip),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/Login');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_have_account_back_to_login),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
