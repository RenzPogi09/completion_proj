import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:completion_proj/model/friend_request_model.dart';
import 'package:completion_proj/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Helper class to hold both the request and sender details
class FriendRequestItem {
  final FriendRequestModel request;
  final UserModel sender;

  FriendRequestItem({required this.request, required this.sender});
}

class FriendProvider extends ChangeNotifier {
  //dito mag istore yung mga friends mo
  List<UserModel> friends = [];
  bool _isLoading = true;
  StreamSubscription? _friendsSubscription;

  // dito naman magstore yung users na dimo pa friends
  // just to show in suggestions so you can add them
  List<UserModel> suggestions = [];

  // Map to track pending requests sent by current user: { receiverId: requestId }
  Map<String, String> sentRequests = {};

  // Incoming friend requests list
  //dito mag istore you mga friend requests
  List<FriendRequestItem> incomingRequests = [];
  StreamSubscription? _requestsSubscription;

  StreamSubscription<User?>? _authSubscription;

  bool get isLoading => _isLoading;

  // Constructor - listens to auth state changes automatically
  FriendProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        listenToFriends();
        listenToFriendRequests();
      } else {
        friends.clear();
        suggestions.clear();
        sentRequests.clear();
        incomingRequests.clear();
        _friendsSubscription?.cancel();
        _requestsSubscription?.cancel();
        _friendsSubscription = null;
        _requestsSubscription = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  //Listen to current user's friends in real-time
  void listenToFriends() {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) {
      friends.clear();
      _isLoading = false;
      notifyListeners();
      return;
    }

    friends.clear();
    _isLoading = true;
    notifyListeners();

    _friendsSubscription?.cancel();
    _friendsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('friends')
        .snapshots()
        .listen((snapshot) async {
          List<UserModel> friendList = [];

          for (var doc in snapshot.docs) {
            final friendUid = doc.id;
            // Never include current user
            if (friendUid == myUid) continue;

            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUid)
                .get();

            if (userDoc.exists) {
              friendList.add(
                UserModel.fromMap(
                  userDoc.data() as Map<String, dynamic>,
                  uid: userDoc.id,
                ),
              );
            }
          }

          friends = friendList;
          _isLoading = false;
          notifyListeners();
        });
  }

  // Listen to incoming friend requests in real-time
  void listenToFriendRequests() {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    _requestsSubscription?.cancel();
    _requestsSubscription = FirebaseFirestore.instance
        .collection('friendRequests')
        .where('receiverId', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
          List<FriendRequestItem> items = [];

          // for loop kase list yung snapshot na binibigay ng snapshot.docs
          // then iterate each
          for (var doc in snapshot.docs) {
            // minodel lang para yung map{}, isang friendRequest sa collection
            //firebase
            final request = FriendRequestModel.fromMap(doc.data(), id: doc.id);

            //para malaman kung sino yung nagsend ng friend request
            //gamit yung user ID niya
            final senderDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(request.senderId)
                .get();

            if (senderDoc.exists) {
              //ginagawa lang ulit na model yung map na galing sa firestore
              final senderUser = UserModel.fromMap(
                senderDoc.data() as Map<String, dynamic>,
                uid: senderDoc.id,
              );

              items.add(
                FriendRequestItem(request: request, sender: senderUser),
              );
            }
          }

          incomingRequests = items;
          notifyListeners();
        });
  }

  // Fetch all users who are not yourself and not yet your friends
  Future<void> fetchSuggestions() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    _isLoading = true;
    notifyListeners();

    // Get all users from Firestore
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    // Get list of current friend IDs to filter them out
    final friendUids = friends.map((f) => f.uid).toSet();

    List<UserModel> result = [];
    for (var doc in snapshot.docs) {
      final user = UserModel.fromMap(doc.data(), uid: doc.id);

      // Only add if hindi ikaw and not already a friend
      if (user.uid != myUid && !friendUids.contains(user.uid)) {
        result.add(user);
      }
    }

    // Fetch existing pending requests sent by you
    final reqSnapshot = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('senderId', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .get();

    Map<String, String> requestMap = {};
    for (var doc in reqSnapshot.docs) {
      final data = doc.data();
      final receiverId = data['receiverId'] as String?;
      if (receiverId != null) {
        requestMap[receiverId] = doc.id;
      }
    }

    sentRequests = requestMap;
    suggestions = result;
    _isLoading = false;
    notifyListeners();
  }

  // Send a friend request to a suggested user
  Future<void> sendFriendRequest(String receiverId) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    // generate one document in friendRequests
    final docRef = FirebaseFirestore.instance
        .collection('friendRequests')
        .doc();

    final request = FriendRequestModel(
      id: docRef.id,
      senderId: myUid,
      receiverId: receiverId,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    // Save to Firestore friendRequests collection
    await docRef.set(request.toMap());

    // Record as sent request so UI shows "Cancel Request"
    sentRequests[receiverId] = docRef.id;
    notifyListeners();
  }

  // Cancel a pending friend request
  Future<void> cancelFriendRequest(String receiverId) async {
    final requestId = sentRequests[receiverId];
    if (requestId != null) {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(requestId)
          .delete();

      sentRequests.remove(receiverId);
      notifyListeners();
    }
  }

  // Accept an incoming friend request
  Future<void> acceptFriendRequest(FriendRequestItem item) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Delete request from friendRequests (or mark accepted)
    final requestDoc = firestore
        .collection('friendRequests')
        .doc(item.request.id);
    batch.delete(requestDoc);

    //  Add to current user's friends subcollection
    final myFriendDoc = firestore
        .collection('users')
        .doc(myUid)
        .collection('friends')
        .doc(item.sender.uid);
    batch.set(
      myFriendDoc,
      FriendModel(uid: item.sender.uid, addedAt: DateTime.now()).toMap(),
    );

    // Add to sender's friends subcollection
    final theirFriendDoc = firestore
        .collection('users')
        .doc(item.sender.uid)
        .collection('friends')
        .doc(myUid);
    batch.set(
      theirFriendDoc,
      FriendModel(uid: myUid, addedAt: DateTime.now()).toMap(),
    );

    await batch.commit();

    // Remove from incoming list immediately
    incomingRequests.removeWhere((req) => req.request.id == item.request.id);
    // Add to local friends list immediately
    if (item.sender.uid != myUid && !friends.any((f) => f.uid == item.sender.uid)) {
      friends.add(item.sender);
    }
    notifyListeners();
  }

  // Decline an incoming friend request
  Future<void> declineFriendRequest(FriendRequestItem item) async {
    await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(item.request.id)
        .delete();

    incomingRequests.removeWhere((req) => req.request.id == item.request.id);
    notifyListeners();
  }

  Future<void> unfriend(String friendUid) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Delete from your friends subcollection
    final myFriendDoc = firestore
        .collection('users')
        .doc(myUid)
        .collection('friends')
        .doc(friendUid);
    batch.delete(myFriendDoc);

    // Delete from their friends subcollection
    final theirFriendDoc = firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(myUid);
    batch.delete(theirFriendDoc);

    await batch.commit();

    friends.removeWhere((friend) => friend.uid == friendUid);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _friendsSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }
}
