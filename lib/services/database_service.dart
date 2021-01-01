import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import '../utilities/constants.dart';

class DatabaseService {
  static Future<User> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot = await usersRef.doc(userId).get();
    if (userDocSnapshot.exists) {
      return User.fromDoc(userDocSnapshot);
    }
    return User();
  }

  static Future<void> updateUser(User user) {
    return usersRef.doc(user.id).update({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
    });
  }

  static void createPost(Post post) {
    postsRef.add({
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

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await postsRef
        .doc(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        userPostsSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Stream<QuerySnapshot> posts(String userId) {
    return postsRef.orderBy('timestamp', descending: true).snapshots();
  }

  static Stream<QuerySnapshot> mypPosts(String userId) {
    return postsRef.where('authorId', isEqualTo: userId).snapshots();
  }

  static void likePost(Post post, String userId) {
    likesRef.doc(post.id).collection('usersLikes').doc(userId).set({});
    addActivityItem(post.authorId, post, null);
  }

  static void unLike(String postId, String userId) {
    likesRef.doc(postId).collection('usersLikes').doc(userId).delete();
  }

  static Stream<QuerySnapshot> postLikes(String postId) {
    return likesRef.doc(postId).collection('usersLikes').snapshots();
  }

  static void addComment(Post post, String authorId, String content) {
    commentsRef.doc(post.id).collection('comments').doc().set({
      'content': content,
      'authorId': authorId,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });

    addActivityItem(authorId, post, content);
  }

  static Stream<QuerySnapshot> comments(String postId) {
    return commentsRef
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static void addActivityItem(String currentUserId, Post post, String comment) {
    activitiesRef.doc(post.authorId).collection('userActivities').add({
      'fromUserId': currentUserId,
      'postId': post.id,
      'postImageUrl': post.imageUrl,
      'comment': comment,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .doc(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .get();
    List<Activity> activity = userActivitiesSnapshot.docs
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    return activity;
  }

  static Future<Post> getUserPost(String userId, String postId) async {
    DocumentSnapshot postDocSnapshot = await postsRef.doc(postId).get();
    return Post.fromDoc(postDocSnapshot);
  }
}
