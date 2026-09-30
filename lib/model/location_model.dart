import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String uid;
  final double latitude;
  final double longitude;
  final bool isSharing;
  final List<String> sharedWith;
  final DateTime updatedAt;

  LocationModel({
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.isSharing,
    this.sharedWith = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'isSharing': isSharing,
      'sharedWith': sharedWith,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    DateTime parsedDate;
    final rawDate = map['updatedAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return LocationModel(
      uid: (map['uid'] as String?) ?? uid ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      isSharing: (map['isSharing'] as bool?) ?? false,
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      updatedAt: parsedDate,
    );
  }

  factory LocationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return LocationModel.fromMap(data, uid: doc.id);
  }
}
