import 'package:completion_proj/providers/friend_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendRequestScreen extends StatelessWidget {
  const FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      //showing it as list comes from FriendProvider class
      body: Consumer<FriendProvider>(
        builder: (context, friendProvider, child) {
          if (friendProvider.incomingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No pending friend requests",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: friendProvider.incomingRequests.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              /*one friend req
                model yung friendRequest (FriendRequestItem)
                sa FriendRequestModel may dalawa siyang pwede mo makuhang information:
                1. request -> yung mismong friend request na pinadala ni user (naka model din siya)
                2. sender -> model din siya UserModel, UserModel == one user
                kaya inaaccess mo yung details dito  friendRequest.sender.kung anonng kailangan mo
              */
              final friendRequest = friendProvider.incomingRequests[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 175, 175, 175),
                  foregroundColor: Colors.white,
                  child: Text(
                    friendRequest.sender.username.isNotEmpty
                        ? friendRequest.sender.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  friendRequest.sender.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  friendRequest.sender.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept Button
                    ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<FriendProvider>()
                            .acceptFriendRequest(friendRequest);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You and ${friendRequest.sender.username} are now friends!',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          62,
                          143,
                          243,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 8),

                    // Decline Button
                    OutlinedButton(
                      onPressed: () async {
                        await context
                            .read<FriendProvider>()
                            .declineFriendRequest(friendRequest);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Declined request from ${friendRequest.sender.username}.',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
