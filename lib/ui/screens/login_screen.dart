import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/location_screen.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String email;
  String password;
  String _loginError;
  bool isLoading;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
      ModalProgressHUD(
        inAsyncCall: isLoading ?? false,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            title: Text(
              'Login to account',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: kAccentColor,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 50,
                horizontal: 25,
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20
                    ),
                    child: SizedBox(
                      height: 30,
                      child: Hero(
                        child: kKompraWordLogo,
                        tag: kTegaioWordLogoHeroTag,
                      ),
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      if (_loginError != null) {
                        setState(() {
                          _loginError = null;
                        });
                      }
                      email = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Email required';
                      } else if (_loginError == 'ERROR_USER_NOT_FOUND' || _loginError == 'ERROR_INVALID_EMAIL') {
                        return 'Invalid email';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter your email',
                      labelText: 'Email',
                    ),
                  ),

                  SizedBox(height: 15),


                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onChanged: (value) {
                      if (_loginError != null) {
                        setState(() {
                          _loginError = null;
                        });
                      }
                      password = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Password required';
                      } else if(value.length < 6) {
                        return 'Password must be at least 6 characters';
                      } else if (_loginError == 'ERROR_WRONG_PASSWORD') {
                        return 'Invalid password';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter password',
                      labelText: 'Password',
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: DefaultFAB(
              icon: Icons.arrow_forward,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  print(email);
                  print(password);
                  AuthResult existingUser;
                  try {
                    setState(() {isLoading = true;});
                    existingUser = await FirebaseTasks.logInUserWithEmailAndPass(
                      email: email,
                      password: password,
                    );
                  } on PlatformException catch (error) {
                    print('Log in error: ${error.code}');
                    _formKey.currentState.setState(() {
                      isLoading = false;
                      _loginError = error.code;
                      _formKey.currentState.validate();
                    });
                  }
                  if(existingUser != null) {
                    setState(() {isLoading = false;});
                    Navigator.of(context).pushNamed(LocationScreen.id);
                    await FirebaseTasks.getClient(email: email).then((client) {
                      Provider.of<CurrentUser>(context, listen: false).client = client;
                      print('Current user: ${Provider.of<CurrentUser>(context, listen: false).client.clientEmail}');
                    });
                  }
                }
              },
          ),
        ),
      ),
    );
  }
}
