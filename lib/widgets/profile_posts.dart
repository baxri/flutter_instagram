import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/widgets/widgets.dart';

import '../models/models.dart';
import '../services/database_service.dart';

class ProfilePosts extends StatefulWidget {
  final User user;

  const ProfilePosts({Key key, this.user}) : super(key: key);
  @override
  _ProfilePostsState createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  int _displayPosts = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toggleButtons(),
        _posts(),
      ],
    );
  }

  Widget _toggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(
              Icons.grid_on,
              size: 25.0,
              color: _displayPosts == 0 ? Colors.black : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _displayPosts = 0;
              });
            }),
        IconButton(
            icon: Icon(
              Icons.list,
              size: 25.0,
              color: _displayPosts == 1 ? Colors.black : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _displayPosts = 1;
              });
            })
      ],
    );
  }

  Widget _posts() {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.mypPosts(widget.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            );
          }

          if (snapshot?.data?.docs?.length == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Center(
                child: Text(
                  'You do not have posts yest :(',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ),
            );
          }

          return _displayPosts == 0
              ? _buildGrid(snapshot?.data?.docs ?? [])
              : _buildList(snapshot?.data?.docs ?? []);
        });
  }

  Widget _buildList(List<QueryDocumentSnapshot> posts) {
    return Column(
      children: posts.map((element) {
        final Post post = Post.fromDoc(element);

        return PostView(
          post: post,
        );
      }).toList(),
    );
  }

  Widget _buildGrid(List<QueryDocumentSnapshot> posts) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: posts.map((element) {
        final Post post = Post.fromDoc(element);

        return GridTile(
          child: Image(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(post.imageUrl)),
        );
      }).toList(),
    );
  }
}
