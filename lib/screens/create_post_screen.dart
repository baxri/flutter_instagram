import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/services/database_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../state/UserState.dart';

class CreatePostScreen extends StatefulWidget {
  final PageController pageController;

  const CreatePostScreen({Key key, this.pageController}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _picker = ImagePicker();

  final _captionController = TextEditingController();

  // State variables
  File _imageFile;
  bool isSubmiting = false;

  _handleImage(ImageSource source) async {
    // Close the action sheet
    Navigator.of(context).pop();

    final pickedFile = await _picker.getImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final croppedImage = await _cropImage(file);

      setState(() {
        _imageFile = croppedImage;
      });
    }
  }

  Future<File> _cropImage(File imageFile) async {
    return await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
  }

  _submit() async {
    if (!isSubmiting &&
        _imageFile != null &&
        _captionController.text.isNotEmpty) {
      setState(() {
        isSubmiting = true;
      });

      String imageUrl = await StorageService.uploadPost(_imageFile);
      String caption = _captionController.text;

      final post = Post(
          imageUrl: imageUrl,
          caption: caption,
          likes: {},
          authorId:
              Provider.of<UserState>(context, listen: false).currentUserId,
          timestamp: Timestamp.fromDate(DateTime.now()));

      DatabaseService.createPost(post);

      _captionController.clear();

      setState(() {
        _imageFile = null;
        isSubmiting = false;
      });

      // Go to fed screen
      widget.pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  _pickImage() {
    Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                  onPressed: () {
                    _handleImage(ImageSource.camera);
                  },
                  child: Text('Take Photo')),
              CupertinoActionSheetAction(
                  onPressed: () {
                    _handleImage(ImageSource.gallery);
                  },
                  child: Text('Choose from gallery'))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel')),
          );
        });
  }

  _androidDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: Text('Add Photo'),
            children: [
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () {
                  _handleImage(ImageSource.camera);
                },
              ),
              SimpleDialogOption(
                child: Text('Choose from gallery'),
                onPressed: () {
                  _handleImage(ImageSource.gallery);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2.0,
          title: Text(
            'Create post',
            style: TextStyle(color: Colors.black),
          ),
          actions: [IconButton(icon: Icon(Icons.add), onPressed: _submit)],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                isSubmiting
                    ? LinearProgressIndicator()
                    : const SizedBox.shrink(),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                      color: Colors.grey[300],
                      width: width,
                      height: width,
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 150.0,
                            )),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
              ],
            ),
          ),
        ));
  }
}
