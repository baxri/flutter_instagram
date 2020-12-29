import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String profileImageUrl;
  final String email;
  final String bio;

  User({this.id, this.name, this.profileImageUrl, this.email, this.bio});

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
        id: doc.id,
        name: doc.get('name'),
        profileImageUrl: doc.get('profileImageUrl'),
        email: doc.get('email'),
        bio: doc.data()['bio'] ?? '');
  }
}
