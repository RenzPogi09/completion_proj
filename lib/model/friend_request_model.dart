
class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FriendRequestModel. fromMap(Map<String, dynamic> map, {String? id}) {
    
    return FriendRequestModel(
      id: id ?? (map['id'] as String? ?? ''),
      senderId: (map['senderId'] as String?) ?? '',
      receiverId: (map['receiverId'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

}
