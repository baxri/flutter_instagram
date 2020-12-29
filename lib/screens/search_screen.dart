import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/screens.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchContoller = TextEditingController();
  Future<QuerySnapshot> _users;

  @override
  void initState() {
    _searchContoller.addListener(() {
      print(_searchContoller.text);

      setState(() {
        // Just force to update UI on change
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchContoller.dispose();

    super.dispose();
  }

  Widget _builduserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey,
          backgroundImage: user.profileImageUrl.isNotEmpty
              ? CachedNetworkImageProvider(user.profileImageUrl)
              : AssetImage('assets/images/user_placeholder.jpg')),
      title: Text(user.name),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(
                  userId: user.id,
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          elevation: 1.0,
          title: TextField(
            controller: _searchContoller,
            style: TextStyle(fontSize: 14.0),
            decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                contentPadding: const EdgeInsets.only(top: 9.0, bottom: 0.0),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                hintText: 'Search',
                prefixIconConstraints: BoxConstraints(maxHeight: 35.0),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(right: 10.0, left: 10.0),
                  height: 35.0,
                  child: Icon(
                    Icons.search,
                    size: 20.0,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(maxHeight: 35.0),
                suffixIcon: _searchContoller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20.0,
                        ),
                        onPressed: () {
                          _searchContoller.clear();
                          setState(() {
                            _users = null;
                          });
                        })
                    : SizedBox.shrink()),
            onSubmitted: (value) async {
              setState(() {
                _users = DatabaseService.searchUsers(value);
              });
            },
          ),
        ),
        body: _users == null
            ? Center(
                child: Text('Let\'s type "George" to test search! ))'),
              )
            : FutureBuilder(
                future: _users,
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    );
                  }

                  if (snapshot.data.documents.length == 0) {
                    return Center(
                        child: Text('No users found! Please try again.'));
                  }

                  return ListView.builder(
                    itemBuilder: (_, index) {
                      User user = User.fromDoc(snapshot.data.documents[index]);

                      return _builduserTile(user);
                    },
                    itemCount: snapshot.data.documents.length,
                  );
                }));
  }
}
