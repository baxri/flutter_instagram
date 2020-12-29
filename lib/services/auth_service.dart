import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import '../screens/screens.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static void signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User user = userCredential.user;

      if (user != null) {
        _firestore.collection('/users').doc(user.uid).set({
          'name': name,
          'email': email,
          'profileImageUrl': '',
        });
      }

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Alert.alert(context, 'Signup', 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Alert.alert(
            context, 'Signup', 'The account already exists for that email.');
      }
    } catch (e) {
      Alert.alert(context, 'Signup', 'Can\'t make signup!');
    }
  }

  static void login(BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Alert.alert(context, 'Login', 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Alert.alert(context, 'Login', 'Wrong password provided for that user.');
      }
    }
  }

  static void logout(context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed(LoginScreen.id);
  }
}
