import 'package:flutter/services.dart';
import 'package:kompra/data/firebase_backend_connections.dart';
import 'package:kompra/domain/models/client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/categories_screen.dart';
import 'package:kompra/ui/screens/location_chooser_screen.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpScreen extends StatefulWidget {
  static String id = 'register_screen';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  String _signupError;
  String email;
  String firstName;
  String lastName;
  String phoneNum;
  String password;
  String rePassword;
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
              'Create an account',
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
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      firstName = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'First name required';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter your first name',
                      labelText: 'First Name',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      lastName = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Last name required';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter your last name',
                      labelText: 'Last Name',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      phoneNum = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Phone number required';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter phone number',
                      labelText: 'Phone Number',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      if (_signupError != null) {
                        setState(() {
                          _signupError = null;
                        });
                      }
                      email = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Email required';
                      } else if (_signupError == 'ERROR_EMAIL_ALREADY_IN_USE') {
                        return 'This email is already being used';
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
                      password = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Password required';
                      } else if(value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter password',
                      labelText: 'Password',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onChanged: (value) {
                      rePassword = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Please re-enter password';
                      } else if(value != password) {
                        return 'Passwords does not match';
                      } else if(value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Re-enter password',
                      labelText: 'Re-enter Password',
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
                AuthResult result;
                try {
                  setState(() {isLoading = true;});
                  result = await FirebaseTasks.createNewUserWithEmailAndPass(
                      email: email,
                      password: password,
                      name: ('$firstName $lastName'),
                      phoneNum: phoneNum
                  );
                } on PlatformException catch (error) {
                  print('Sign up error: ${error.code}');
                  setState(() {isLoading = false;});
                  if(error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
                    result = await FirebaseTasks.createClientAccountForExistingShopper(
                        email: email,
                        password: password,
                        name: ('$firstName $lastName'),
                        phoneNum: phoneNum
                    );
                  } else {
                    _formKey.currentState.setState(() {
                      _signupError = error.code;
                      _formKey.currentState.validate();
                    });
                  }
                }
                if(result != null) {
                  setState(() {isLoading = true;});
                  FirebaseUser user = await FirebaseTasks.getCurrentUser();
                  print(user.email);
                  Provider.of<CurrentUser>(context, listen: false).client =
                      Client(
                        clientEmail: email,
                        clientName: ('$firstName $lastName'),
                        clientPhoneNum: phoneNum,
                      );
                  print('Current user: ${Provider.of<CurrentUser>(context, listen: false).client}');
                  Navigator.of(context).pushNamed(CategoriesScreen.id);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
