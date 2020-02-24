import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kompra/data/firebase_backend_connections.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/grocery_items_screen.dart';
import 'package:kompra/ui/screens/scratch.dart';
import 'constants.dart';
import 'package:kompra/ui/screens/finding_shopper_screen.dart';
import 'package:kompra/ui/screens/location_screen.dart';
import 'package:kompra/ui/screens/grocery_list_form_screen.dart';
import 'package:kompra/ui/screens/loading_screen.dart';
import 'package:kompra/ui/screens/login_screen.dart';
import 'package:kompra/ui/screens/shopper_accepted_screen.dart';
import 'package:kompra/ui/screens/sign_up_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'domain/firebase_tasks.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<CurrentUser>(create: (context) => CurrentUser(),),
      ChangeNotifierProvider<PendingTransaction>(create: (context) => PendingTransaction(),),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initialRoute;

  void checkIfLocationEnabled () async {
    Location locationService = Location();
    bool isEnabled = await locationService.serviceEnabled();
    if (!isEnabled) {
      locationService.requestService();
    }
  }

  Future<void> getInitialRoute() {
    FirebaseTasks.getCurrentUser().then((firebaseUser) {
      if (initialRoute == null) {
        setState(() {
          if (firebaseUser == null) {
            //signed out
            initialRoute = WelcomeScreen.id;
          } else {
            //signed in
            initialRoute = LocationScreen.id;
            FirebaseTasks.getClient(email: firebaseUser.email).then((client) {
              Provider.of<CurrentUser>(context, listen: false).client = client;
              print('Current user: ${Provider.of<CurrentUser>(context, listen: false).client.clientEmail}');
            });
          }
        });
      }
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
//    checkIfLocationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    getInitialRoute();
//    return (initialRoute == null) ? LoadingScreen() : MaterialApp(
    return MaterialApp(
      title: 'Kompra',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      initialRoute: GroceryItemsScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LocationScreen.id: (context) => LocationScreen(),
        FindingShopperScreen.id: (context) => FindingShopperScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        ShopperAcceptedScreen.id: (context) => ShopperAcceptedScreen(),
        GroceryListFormScreen.id: (context) => GroceryListFormScreen(),
        LoadingScreen.id: (context) => LoadingScreen(),
        ScratchScreen.id: (context) => ScratchScreen(),
        GroceryItemsScreen.id : (context) => GroceryItemsScreen(),
      },
    );
  }
}
