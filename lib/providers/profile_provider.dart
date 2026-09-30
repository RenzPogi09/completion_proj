import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:completion_proj/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel? userDetail;
  bool isLoading = true;

  StreamSubscription<User?>? _authSubscription;

  ProfileProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        getData(user.uid);
      } else {
        userDetail = null;
        isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> getData(String uid) async {
    try {
      isLoading = true;
      notifyListeners();

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        userDetail = UserModel.fromMap(doc.data()!, uid: doc.id);
      }
    } catch (e) {
      debugPrint('Error getting profile data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
