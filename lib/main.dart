import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/screens/home_screen.dart';

import 'package:provider/provider.dart';

import './screens/screens.dart';

import './state/UserState.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Widget _initScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Listen to firebase auth state changes

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasData) {
          Provider.of<UserState>(context, listen: false).currentUserId =
              snapshot.data.uid;

          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider(
              create: (_) => UserState(),
              child: MaterialApp(
                title: 'Istagram',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    primaryIconTheme: Theme.of(context)
                        .primaryIconTheme
                        .copyWith(color: Colors.black)),
                home: _initScreen(),
                routes: {
                  HomeScreen.id: (_) => HomeScreen(),
                  EditProfileScreen.id: (_) => EditProfileScreen(),
                  LoginScreen.id: (_) => LoginScreen(),
                  SignupScreen.id: (_) => SignupScreen(),
                  FeedScreen.id: (_) => FeedScreen(),
                },
              ),
            );
          }

          // Show loading before firebase app is initialized using futurebuilder
          return LoadingScreen();
        });
  }
}
