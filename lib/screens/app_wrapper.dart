import 'package:completion_proj/providers/friend_provider.dart';
import 'package:completion_proj/providers/location_provider.dart';
import 'package:completion_proj/screens/friends_section/friends_screen.dart';
import 'package:completion_proj/screens/map_section/map_screen.dart';
import 'package:completion_proj/screens/profile_section/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();

    // Keep location provider's friend stream in sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchFriendsLocations(
        friendProvider.friends,
      );
    });

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(111, 214, 217, 220),
        indicatorColor: const Color.fromARGB(50, 40, 103, 180),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(color: Color(0xFF10427F)),
        ),
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() {
            currentPage = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map, color: Color.fromARGB(255, 62, 143, 243)),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.group, color: Color.fromARGB(255, 62, 143, 243)),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Color.fromARGB(255, 62, 143, 243)),
            label: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: currentPage,
            children: [
              MapScreen(),
              FriendsScreen(),
              ProfileScreen(
                // swithc tab to friends section when tapping friends container
                //in profile section
                onNavigateToFriends: () {
                  setState(() {
                    currentPage = 1;
                  });
                },
              ),
            ],
          ),
         
        ],
      ),
    );
  }
}
