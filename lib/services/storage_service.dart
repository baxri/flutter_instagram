import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_instagram/utilities/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../utilities/constants.dart';

class StorageService {
  static Future<String> uploadFile(String existingProfileUrl, File file) async {
    String photoId = Uuid().v4();
    File compresedFile = await compressImage(photoId, file);

    if (existingProfileUrl.isNotEmpty) {
      photoId =
          new RegExp(r'userProfile_(.*).jpg').firstMatch(existingProfileUrl)[1];
    }

    TaskSnapshot result = await profileImagesRef
        .child('userProfile_$photoId.jpg')
        .putFile(compresedFile);

    return await result.ref.getDownloadURL();
  }

  static Future<String> uploadPost(File file) async {
    String photoId = Uuid().v4();
    File compresedFile = await compressImage(photoId, file);

    TaskSnapshot result =
        await postImagesRef.child('post_$photoId.jpg').putFile(compresedFile);

    return await result.ref.getDownloadURL();
  }

  static Future<File> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    return await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img$photoId.jpg',
      quality: 70,
    );
  }
}
