import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/screens/comments_screen.dart';
import 'package:flutter_instagram/state/UserState.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../utilities/constants.dart';

class PostView extends StatefulWidget {
  final Post post;

  const PostView({Key key, this.post}) : super(key: key);

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final String currentUserId = Provider.of<UserState>(context).currentUserId;

    return StreamBuilder<DocumentSnapshot>(
        stream: usersRef.doc(post.authorId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            final user = User.fromDoc(snapshot.data);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: user.profileImageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(user.profileImageUrl)
                            : AssetImage('assets/images/user_placeholder.jpg'),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        user.name,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                AnimHeart(
                  post: post,
                  user: currentUserId,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: DatabaseService.postLikes(post.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox.shrink();
                            }

                            final likesLength = snapshot.data.docs.length;

                            final bool liked = likesLength > 0
                                ? snapshot.data.docs
                                    .firstWhere((e) => e.id == currentUserId)
                                    .exists
                                : false;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          liked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 30.0,
                                          color:
                                              liked ? Colors.red : Colors.black,
                                        ),
                                        onPressed: () {
                                          if (liked) {
                                            DatabaseService.unLike(
                                                post.id, currentUserId);
                                          } else {
                                            DatabaseService.likePost(
                                                post, currentUserId);
                                          }
                                        }),
                                    IconButton(
                                        icon: Icon(
                                          Icons.comment_outlined,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) {
                                            return CommentsScreen(
                                              likeCount:
                                                  snapshot?.data?.docs?.length,
                                              post: post,
                                            );
                                          }));
                                        })
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Text(
                                    '${snapshot?.data?.docs?.length?.toString()} Likes',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            );
                          }),
                      SizedBox(
                        height: 4.0,
                      ),
                      Row(
                        children: [
                          Container(
                            margin:
                                const EdgeInsets.only(left: 12.0, right: 6.0),
                            child: Text(
                              user.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              post.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                    ],
                  ),
                )
              ],
            );
          }

          return SizedBox.shrink();
        });
  }
}

class AnimHeart extends StatefulWidget {
  const AnimHeart({
    Key key,
    @required this.post,
    this.user,
  }) : super(key: key);

  final Post post;
  final String user;

  @override
  _AnimHeartState createState() => _AnimHeartState();
}

class _AnimHeartState extends State<AnimHeart> {
  bool _heartAnim = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        DatabaseService.likePost(widget.post, widget.user);
        setState(() {
          _heartAnim = true;
        });
        Timer(Duration(milliseconds: 350), () {
          setState(() {
            _heartAnim = false;
          });
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.post.imageUrl),
                    fit: BoxFit.cover)),
          ),
          _heartAnim
              ? Animator(
                  duration: Duration(milliseconds: 400),
                  tween: Tween(begin: 0.5, end: 1.4),
                  curve: Curves.elasticOut,
                  builder: (_, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Opacity(
                      opacity: 0.8,
                      child: Icon(
                        Icons.favorite,
                        size: 100.0,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
