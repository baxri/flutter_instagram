import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../widgets/widgets.dart';

class FeedScreen extends StatefulWidget {
  static const String id = '/feed_screen';

  final String userId;

  const FeedScreen({Key key, this.userId}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
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

            if (snapshot.data.docs.length == 0) {
              return Center(
                child: Text(
                  'You do not have posts yest :(',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => Future.delayed(Duration(seconds: 1)),
              child: ListView.builder(
                itemBuilder: (_, index) {
                  final Post post = Post.fromDoc(snapshot.data.docs[index]);

                  return PostView(
                    post: post,
                  );
                },
                itemCount: snapshot.data.docs.length,
              ),
            );
          }),
    );
  }
}
