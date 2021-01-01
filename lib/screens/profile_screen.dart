import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utilities/constants.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import '../state/UserState.dart';
import '../widgets/widgets.dart';

import '../services/database_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int followerCount = 0;
  int followingCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 1.0,
        title: Text(
          'Instagram',
          style: TextStyle(
              color: Colors.black, fontFamily: 'billabong', fontSize: 35.0),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => AuthService.logout(context))
        ],
      ),
      body: StreamBuilder(
          stream: usersRef.doc(widget.userId).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              );
            }

            final user = User.fromDoc(snapshot.data);

            final String userId = Provider.of<UserState>(context).currentUserId;
            final bool isMyProfile = user.id == userId;

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 40.0, 0.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey,
                          backgroundImage: user.profileImageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(user.profileImageUrl)
                              : AssetImage(
                                  'assets/images/user_placeholder.jpg')),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _stats('12', 'posts'),
                                StreamBuilder<QuerySnapshot>(
                                    stream:
                                        DatabaseService.numFollowers(user.id),
                                    builder: (_, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                            ));
                                      }

                                      return _stats(
                                          snapshot?.data?.docs?.length
                                                  .toString() ??
                                              '0',
                                          'followers');
                                    }),
                                StreamBuilder<QuerySnapshot>(
                                    stream:
                                        DatabaseService.numFollowings(user.id),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                            ));
                                      }
                                      return _stats(
                                          snapshot?.data?.docs?.length
                                                  .toString() ??
                                              '0',
                                          'following');
                                    }),
                              ],
                            ),
                            isMyProfile
                                ? OutlineButton(
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                EditProfileScreen(user: user))),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(fontSize: 15.0),
                                    ))
                                : StreamBuilder(
                                    stream: DatabaseService.isFollowing(
                                        userId, user.id),
                                    builder: (context, snapshot) {
                                      final bool isFollowing =
                                          snapshot.hasData &&
                                              snapshot.data.exists;

                                      return FlatButton(
                                          color: isFollowing
                                              ? Colors.grey[300]
                                              : Colors.blue,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            isFollowing
                                                ? DatabaseService.unFollowUser(
                                                    userId, user.id)
                                                : DatabaseService.followUser(
                                                    userId, user.id);
                                          },
                                          child: Text(
                                            isFollowing ? 'UnFollow' : 'Follow',
                                            style: TextStyle(fontSize: 15.0),
                                          ));
                                    })
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        user.bio ?? 'Bio is empty',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 1.0,
                ),
                ProfilePosts(
                  user: user,
                ),
              ],
            );
          }),
    );
  }

  Widget _stats(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13.0, color: Colors.black54),
        )
      ],
    );
  }
}
