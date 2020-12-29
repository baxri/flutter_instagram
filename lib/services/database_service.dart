import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import '../utilities/constants.dart';

class DatabaseService {
  static Future<void> updateUser(User user) {
    return usersRef.doc(user.id).update({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
    });
  }

  static void createPost(Post post) {
    postsRef.doc(post.authorId).collection('usersPosts').add({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likes': post.likes,
      'authorId': post.authorId,
      'timestamp': post.timestamp,
    });
  }

  static Future<QuerySnapshot> searchUsers(String search) {
    return usersRef.where('name', isGreaterThanOrEqualTo: search).get();
  }

  static Stream<DocumentSnapshot> isFollowing(
      String currecntUSerId, String userId) {
    return followingRef
        .doc(userId)
        .collection('usersFollowing')
        .doc(currecntUSerId)
        .snapshots();
  }

  static Stream<QuerySnapshot> numFollowers(String userId) {
    return followingRef.doc(userId).collection('usersFollowing').snapshots();
  }

  static Stream<QuerySnapshot> numFollowings(String userId) {
    return followersRef.doc(userId).collection('usersFollower').snapshots();
  }

  static void followUser(String currecntUSerId, String userId) {
    followingRef
        .doc(userId)
        .collection('usersFollowing')
        .doc(currecntUSerId)
        .set({});

    followersRef
        .doc(currecntUSerId)
        .collection('usersFollower')
        .doc(userId)
        .set({});
  }

  static void unFollowUser(String currecntUSerId, String userId) {
    followingRef
        .doc(userId)
        .collection('usersFollowing')
        .doc(currecntUSerId)
        .delete();

    followersRef
        .doc(currecntUSerId)
        .collection('usersFollower')
        .doc(userId)
        .delete();
  }

  static Stream<QuerySnapshot> posts(String userId) {
    return postsRef
        .doc(userId)
        .collection('usersPosts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
