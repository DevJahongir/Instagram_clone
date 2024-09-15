import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/services/prefs_service.dart';

import 'auth_service.dart';
import 'log_service.dart';

class FileService{
  static const folder_user = "user_images";
  static const folder_post = "post_images";

  static Future<String> uploadUserImage(File _image) async {
    FirebaseApp app = await Firebase.initializeApp();
    FirebaseStorage _storage = FirebaseStorage.instanceFor(app: app, bucket: 'instaclone-2-4ac0a.appspot.com');

    String uid = AuthService.currentUserId();

    String img_name = uid; //false {cached_network_image}

    var firebaseStorageRef = _storage.ref().child(folder_user).child(img_name);
    var uploadTask = firebaseStorageRef.putFile(_image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    final String downloadUrl = await firebaseStorageRef.getDownloadURL();
    print(downloadUrl);
    return downloadUrl;
  }

  static Future<String> uploadPostImage(File _image) async {
    FirebaseApp app = await Firebase.initializeApp();
    FirebaseStorage _storage = FirebaseStorage.instanceFor(app: app, bucket: 'instaclone-2-e33a7.appspot.com');

    String uid = await Prefs.loadUserId();

    String img_name = "${uid}_${DateTime.now()}";
    var firebaseStorageRef = _storage.ref().child(folder_post).child(img_name);
    var uploadTask = firebaseStorageRef.putFile(_image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    final String downloadUrl = await firebaseStorageRef.getDownloadURL();
    LogService.i(downloadUrl);
    return downloadUrl;
  }
}