import 'package:completion_proj/providers/friend_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch suggestions when this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendProvider>().fetchSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suggestions"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      body: Consumer<FriendProvider>(
        builder: (context, friendProvider, child) {
          if (friendProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (friendProvider.suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    "No suggestions found",
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
            itemCount: friendProvider.suggestions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = friendProvider.suggestions[index];
              final isRequested = friendProvider.sentRequests.containsKey(
                user.uid,
              );

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 175, 175, 175),
                  foregroundColor: Colors.white,
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                trailing: isRequested
                    ? OutlinedButton(
                        onPressed: () async {
                          // call the method from provider class
                          await context
                              .read<FriendProvider>()
                              .cancelFriendRequest(user.uid);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Request to ${user.username} cancelled.',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Cancel'),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<FriendProvider>()
                              .sendFriendRequest(user.uid);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Friend request sent to ${user.username}!',
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Add Friend'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
