import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}

Future<bool> addFile(
    String name, String? type, DateTime date, String? url) async {
  try {
    CollectionReference files = FirebaseFirestore.instance.collection('Files');
    await files.add({'name': name, 'type': type, 'date': date, 'url': url});

    return true;
  } catch (e) {
    return false;
  }
}
