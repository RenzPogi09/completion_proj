import 'package:completion_proj/providers/friend_provider.dart';
import 'package:completion_proj/providers/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToFriends;
  const ProfileScreen({super.key, this.onNavigateToFriends});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final friendProvider = context.watch<FriendProvider>();
    final userDetails = profileProvider.userDetail;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // User Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color.fromARGB(255, 175, 175, 175),
                foregroundColor: Colors.white,
                child: Text(
                  userDetails != null && userDetails.username.isNotEmpty
                      ? userDetails.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Username
              Text(
                userDetails?.username ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              // Email
              Text(
                userDetails?.email ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 28),

              // Friends Card
              GestureDetector(
                onTap: onNavigateToFriends,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const .all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 235, 243, 255),
                              borderRadius: .circular(10),
                            ),
                            child: const Icon(
                              Icons.people_alt_outlined,
                              color: Color.fromARGB(255, 62, 143, 243),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Friends',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const .symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: .circular(12),
                        ),
                        child: Text(
                          "${friendProvider.friends.length}",
                          style: TextStyle(
                            fontWeight: .bold,
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Logout Card
              Material(
                color: Colors.white,
                borderRadius: .circular(14),
                shadowColor: Colors.black.withValues(alpha: 0.08),
                elevation: 2,
                child: InkWell(
                  borderRadius: .circular(14),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Padding(
                    padding: const .symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const .all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: .circular(10),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Logout',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
