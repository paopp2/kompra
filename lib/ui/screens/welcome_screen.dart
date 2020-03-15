import 'package:flutter/material.dart';
import 'package:kompra/ui/screens/sign_up_screen.dart';
import 'login_screen.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/ui/components/rounded_button.dart';

class WelcomeScreen extends StatelessWidget {
  static String id = 'welcome_screen';
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
        Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(80),
                  child: Hero(
                    child: kKompraWordLogo,
                    tag: kTegaioWordLogoHeroTag,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RoundedButton(
                    elevation: 0,
                    child: kSignUpText,
                    onPressed: () {
                      Navigator.pushNamed(context, SignUpScreen.id);
                    },
                    colour: kAccentColor,
                  ),
                  RoundedButton(
                    elevation: 0,
                    child: kLoginText,
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    colour: Colors.white,
                  ),
                  SizedBox(
                    height: constraints.maxHeight * (1/5),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}