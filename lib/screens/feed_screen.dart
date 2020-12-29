import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../utilities/constants.dart';

class FeedScreen extends StatefulWidget {
  static const String id = '/feed_screen';

  final String userId;

  const FeedScreen({Key key, this.userId}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

_buildPost(Post post) {
  return StreamBuilder<DocumentSnapshot>(
      stream: usersRef.doc(post.authorId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final user = User.fromDoc(snapshot.data);

          return Container(
            height: 200,
            child: ListTile(
                title: Text(
              post.caption,
            )),
          );
        }

        return SizedBox.shrink();
      });
}

class _FeedScreenState extends State<FeedScreen> {
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
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService.posts(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              );
            }

            return ListView.builder(
              itemBuilder: (_, index) {
                final Post post = Post.fromDoc(snapshot.data.docs[index]);

                return _buildPost(post);
              },
              itemCount: snapshot.data.docs.length,
            );
          }),
    );
  }
}
