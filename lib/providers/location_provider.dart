import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:completion_proj/model/location_model.dart';
import 'package:completion_proj/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  bool _isSharing = false;
  LatLng? _myLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _friendsLocationSubscription;
  StreamSubscription<User?>? _authSubscription;

  //all of friends locations
  Set<Marker> friendsMarkers = {};
  List<String> _sharedWith = [];
  bool _hasCustomizedSharedWith = false;

  // Getters
  bool get isSharing => _isSharing;
  LatLng? get myLocation => _myLocation;
  List<String> get sharedWith => _sharedWith;
  bool isLoading = false;

  bool isFriendChecked(String friendUid, List<String> allFriendUids) {
    if (_hasCustomizedSharedWith) {
      return _sharedWith.contains(friendUid);
    }
    // Default when never customized: all checked
    return true;
  }

  LocationProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        stopSharing();
        friendsMarkers.clear();
        _sharedWith.clear();
        _hasCustomizedSharedWith = false;
        _myLocation = null;
        _isSharing = false;
        _friendsLocationSubscription?.cancel();
        _friendsLocationSubscription = null;
        notifyListeners();
      } else {
        // Check Firestore on cold start / login
        checkInitialSharingStatus(user.uid);
      }
    });
  }

  // Check Firestore on startup and resume sharing if it was ON
  Future<void> checkInitialSharingStatus(String uid) async {
    try {
      isLoading = true;
      notifyListeners();

      final doc = await FirebaseFirestore.instance
          .collection('locations')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final bool wasSharing = data?['isSharing'] as bool? ?? false;
        if (data != null && data.containsKey('sharedWith')) {
          _sharedWith = List<String>.from(data['sharedWith'] ?? []);
          _hasCustomizedSharedWith = true;
        } else {
          _hasCustomizedSharedWith = false;
          _sharedWith.clear();
        }
        if (wasSharing) {
          // Automatically resumes GPS tracking and updates UI to "Sharing ON"
          await startSharing();
        } else {
          _isSharing = false;
        }
      } else {
        // Newly created account without a location document in Firestore
        _isSharing = false;
        _sharedWith.clear();
        _hasCustomizedSharedWith = false;
      }
    } catch (e) {
      debugPrint('Error checking sharing status: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Start sharing location
  Future<bool> startSharing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Check if GPS / Location service is enabled on the device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get initial GPS position
      //para magload agad
      Position currentPosition = await Geolocator.getCurrentPosition();
      _myLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
      _isSharing = true;

      // Save initial location to Firestore
      await _updateLocationInFirestore(
        uid: user.uid,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        isSharing: true,
      );

      // Listen to real-time GPS changes while app is active
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // update every 5 meters moved
            ),
          ).listen((Position position) {
            // _isSharing = true;
            _myLocation = LatLng(position.latitude, position.longitude);
            notifyListeners();

            // Update coordinates in Firestore
            _updateLocationInFirestore(
              uid: user.uid,
              latitude: position.latitude,
              longitude: position.longitude,
              isSharing: true,
            );
          });

      return true;
    } catch (e) {
      debugPrint('Error in startSharing: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Stop sharing location
  Future<void> stopSharing() async {
    final user = FirebaseAuth.instance.currentUser;

    isLoading = true;
    notifyListeners();

    try {
      // Cancel GPS listener
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      _isSharing = false;

      // Update Firestore to indicate sharing has stopped
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(user.uid)
            .set({
              'isSharing': false,
              'updatedAt': DateTime.now(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error in stopSharing: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to write to Firestore
  Future<void> _updateLocationInFirestore({
    required String uid,
    required double latitude,
    required double longitude,
    required bool isSharing,
  }) async {
    final locationData = LocationModel(
      uid: uid,
      latitude: latitude,
      longitude: longitude,
      isSharing: isSharing,
      sharedWith: _sharedWith,
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('locations')
        .doc(uid)
        .set(locationData.toMap(), SetOptions(merge: true));
  }

  // Toggle sharing with a specific friend
  Future<void> toggleFriendSharing(
    String friendUid,
    List<String> allFriendUids,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // If never customized, start with all current friends selected
    if (!_hasCustomizedSharedWith) {
      _sharedWith = List.from(allFriendUids);
      _hasCustomizedSharedWith = true;
    }

    if (_sharedWith.contains(friendUid)) {
      _sharedWith.remove(friendUid);
    } else {
      _sharedWith.add(friendUid);
    }
    notifyListeners();

    await FirebaseFirestore.instance
        .collection('locations')
        .doc(user.uid)
        .set({
          'sharedWith': _sharedWith,
          'updatedAt': DateTime.now(),
        }, SetOptions(merge: true));
  }

  void fetchFriendsLocations(List<UserModel> friendsList) {
    if (friendsList.isEmpty) {
      _friendsLocationSubscription?.cancel();
      _friendsLocationSubscription = null;
      friendsMarkers.clear();
      notifyListeners();
      return;
    }

    // friends uids
    final friendUids = friendsList.map((friend) => friend.uid).toList();

    // map uid to username for display
    final friendNames = {
      for (var friend in friendsList) friend.uid: friend.username,
    };
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    // cancel existing subscription before starting a new one
    _friendsLocationSubscription?.cancel();

    // fetch the locations of those ids from locations collection
    _friendsLocationSubscription = FirebaseFirestore.instance
        .collection('locations')
        .where(FieldPath.documentId, whereIn: friendUids)
        .where('isSharing', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          friendsMarkers = snapshot.docs
              .where((doc) {
                final data = doc.data();
                // If friend has customized sharedWith list, verify myUid is included
                if (data.containsKey('sharedWith') && data['sharedWith'] != null) {
                  final List<dynamic> sharedWithList = data['sharedWith'];
                  return myUid != null && sharedWithList.contains(myUid);
                }
                // Default: visible to all friends
                return true;
              })
              .map((doc) {
                final location = LocationModel.fromFirestore(doc);
                final String username = friendNames[location.uid] ?? 'Friend';

                return Marker(
                  markerId: MarkerId(location.uid),
                  position: LatLng(location.latitude, location.longitude),
                  infoWindow: InfoWindow(
                    title: username,
                    snippet: 'Sharing location',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRose,
                  ),
                );
              })
              .toSet();

          notifyListeners();
        });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    _friendsLocationSubscription?.cancel();
    super.dispose();
  }
}
