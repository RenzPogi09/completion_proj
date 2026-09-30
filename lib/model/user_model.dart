import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl ?? '',
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserModel(
      uid: (map['uid'] as String?) ?? uid ?? '',
      username: (map['username'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  // factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  //   final data = doc.data() ?? {};
  //   return UserModel.fromMap(data, uid: doc.id);
  // }
}

/* 
users{uid}/friends{}
*/
class FriendModel {
  final String uid;
  final DateTime addedAt;

  FriendModel({required this.uid, required this.addedAt});

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'addedAt': addedAt.millisecondsSinceEpoch};
  }

  factory FriendModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return FriendModel(
      uid: (map['uid'] as String?) ?? uid ?? '',
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int),
    );
  }

  factory FriendModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return FriendModel.fromMap(data, uid: doc.id);
  }
}
