import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  static const String id = '/edit-profile';
  final User user;

  const EditProfileScreen({Key key, this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _picker = ImagePicker();

  bool isSubmiting = false;
  File _profileImage;
  String _name;
  String _bio;

  @override
  void initState() {
    super.initState();

    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  void _handleImagePick() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (isSubmiting) {
      return null;
    }

    final isValid = _formKey.currentState.validate();

    if (isValid) {
      _formKey.currentState.save();

      setState(() {
        isSubmiting = true;
      });

      String profileImageUrl = widget.user.profileImageUrl;

      if (_profileImage != null) {
        profileImageUrl =
            await StorageService.uploadFile(profileImageUrl, _profileImage);
      }

      final User user = User(
          id: widget.user.id,
          name: _name,
          bio: _bio,
          profileImageUrl: profileImageUrl);

      await DatabaseService.updateUser(user);

      setState(() {
        isSubmiting = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.white,
        leadingWidth: 65,
        leading: Container(
          child: TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.of(context).pop()),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
              color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            child: Text(
              'Done',
            ),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              isSubmiting ? LinearProgressIndicator() : const SizedBox.shrink(),
              Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60.0,
                          backgroundColor: Colors.grey,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage)
                              : widget.user.profileImageUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      widget.user.profileImageUrl)
                                  : AssetImage(
                                      'assets/images/user_placeholder.jpg'),
                        ),
                        FlatButton(
                            onPressed: _handleImagePick,
                            child: Text(
                              'Change profile photo',
                              style: TextStyle(
                                  fontSize: 13.0,
                                  color: Theme.of(context).accentColor),
                            )),
                        TextFormField(
                          initialValue: _name,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: 'Type your fullname!',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            isCollapsed: true,
                            prefixIconConstraints:
                                BoxConstraints(maxHeight: 20.0),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(
                                  right: 30.0, left: 20.0),
                              alignment: Alignment.centerLeft,
                              width: 60.0,
                              child: Text('Name',
                                  style: TextStyle(fontSize: 14.0)),
                            ),
                          ),
                          validator: (value) => value.length < 1
                              ? 'Please enter a valid name'
                              : null,
                          onSaved: (value) => _name = value,
                        ),
                        TextFormField(
                          initialValue: _bio,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: 'Tell us about yourself!',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            isCollapsed: true,
                            prefixIconConstraints:
                                BoxConstraints(maxHeight: 20.0),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(
                                  right: 30.0, left: 20.0),
                              alignment: Alignment.centerLeft,
                              width: 60.0,
                              height: 20.0,
                              child:
                                  Text('Bio', style: TextStyle(fontSize: 14.0)),
                            ),
                          ),
                          validator: (value) => value.length < 1
                              ? 'Please enter a valid bio'
                              : null,
                          onSaved: (value) => _bio = value,
                        ),
                        TextFormField(
                          initialValue: _bio,
                          style: TextStyle(fontSize: 16.0),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            isCollapsed: true,
                            prefixIconConstraints:
                                BoxConstraints(maxHeight: 20.0),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(
                                  right: 30.0, left: 20.0),
                              alignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width,
                              height: 20.0,
                              child: Text('Switch to professional account',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Theme.of(context).accentColor)),
                            ),
                          ),
                        ),
                        TextFormField(
                          initialValue: _bio,
                          style: TextStyle(fontSize: 16.0),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            isCollapsed: true,
                            prefixIconConstraints:
                                BoxConstraints(maxHeight: 20.0),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(
                                  right: 30.0, left: 20.0),
                              alignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width,
                              height: 20.0,
                              child: Text('Personal information settings',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Theme.of(context).accentColor)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
