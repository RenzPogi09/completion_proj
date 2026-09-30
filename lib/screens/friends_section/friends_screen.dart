import 'package:completion_proj/providers/friend_provider.dart';
import 'package:completion_proj/providers/location_provider.dart';
import 'package:completion_proj/screens/friends_section/friend_request_screen.dart';
import 'package:completion_proj/screens/friends_section/suggestions_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
          letterSpacing: .2,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chips row: Suggestions & Friend Request
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuggestionsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 223, 223, 223),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Suggestions",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FriendRequestScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 223, 223, 223),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Friend Requests",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "My Friends",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
                letterSpacing: .2,
              ),
            ),
            const SizedBox(height: 10),

            // Friends list scoped inside Consumer
            //naglilisten lang siya sa FriendProvider class na nagbibigay
            //ng list of friends
            Expanded(
              child: Consumer2<FriendProvider, LocationProvider>(
                builder: (context, friendProvider, locationProvider, child) {
                  if (friendProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (friendProvider.friends.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 55,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "No friends added yet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap Suggestions to find and add friends",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: friendProvider.friends.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final friend = friendProvider.friends[index];

                      //checks friends who is sharing location
                      final bool isSharing = locationProvider.friendsMarkers
                          .any((marker) => marker.markerId.value == friend.uid);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color.fromARGB(
                                255,
                                175,
                                175,
                                175,
                              ),
                              foregroundColor: Colors.white,
                              child: Text(
                                friend.username.isNotEmpty
                                    ? friend.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Green (sharing) or Red/Grey (not sharing) indicator badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isSharing ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          friend.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          isSharing ? 'Sharing location' : 'Not sharing',
                          style: TextStyle(
                            color: isSharing
                                ? Colors.green[700]
                                : Colors.grey[600],
                            fontSize: 13,
                            fontWeight: isSharing
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              //getting each tile a friends user id
                              value: friend.uid,
                              onTap: () {
                                context.read<FriendProvider>().unfriend(
                                  friend.uid,
                                );
                              },
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_remove_outlined,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Unfriend',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
