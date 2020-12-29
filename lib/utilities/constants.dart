import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final fireStore = FirebaseFirestore.instance;

final usersRef = fireStore.collection('users');
final postsRef = fireStore.collection('posts');
final followingRef = fireStore.collection('following');
final followersRef = fireStore.collection('followers');

final profileImagesRef = FirebaseStorage.instance.ref().child('/images/users');
final postImagesRef = FirebaseStorage.instance.ref().child('/images/posts');
