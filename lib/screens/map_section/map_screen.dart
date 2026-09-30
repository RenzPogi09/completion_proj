import 'package:completion_proj/providers/friend_provider.dart';
import 'package:completion_proj/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final friendProvider = context.watch<FriendProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchFriendsLocations(
        friendProvider.friends,
      );
    });

    // Build map markers
    Set<Marker> markers = {};
    if (locationProvider.isSharing && locationProvider.myLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: locationProvider.myLocation!,
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }
    if (locationProvider.friendsMarkers.isNotEmpty) {
      markers.addAll(locationProvider.friendsMarkers);
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(16.408917, 120.599756),
              zoom: 14,
            ),
            markers: markers,
            zoomControlsEnabled: false,
            // myLocationEnabled: locationProvider.isSharing,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // 2. Toggle Location Sharing Switch
          Positioned(
            bottom: 40,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    locationProvider.isSharing
                        ? Icons.location_on
                        : Icons.location_off_outlined,
                    color: locationProvider.isSharing
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    locationProvider.isSharing ? 'Sharing ON' : 'Sharing OFF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: locationProvider.isSharing
                          ? Colors.green
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  locationProvider.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Switch(
                          value: locationProvider.isSharing,
                          activeThumbColor: Colors.green,
                          onChanged: (bool enable) async {
                            //store lang ng current location galing sa provider
                            final location = Provider.of<LocationProvider>(
                              context,
                              listen: false,
                            ).myLocation;

                            if (enable) {
                              bool success = await context
                                  .read<LocationProvider>()
                                  .startSharing();
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Location permission denied or GPS disabled.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                //if my laman na yung myLocation (LatLng) animate the camera
                                //position
                              } else if (location != null) {
                                //zooming effect
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(location, 16),
                                );
                              }
                            } else {
                              await context
                                  .read<LocationProvider>()
                                  .stopSharing();
                            }
                          },
                        ),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    offset: const Offset(10, -80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'customize',
                        child: Text("Customize location sharing"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'customize') {
                        _showCustomizeSharingDialog(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Floating window showing list of friends with checkboxes
  void _showCustomizeSharingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer2<FriendProvider, LocationProvider>(
          builder: (context, friendProvider, locationProvider, child) {
            final allFriends = friendProvider.friends;
            final allFriendUids = allFriends.map((f) => f.uid).toList();

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sharing location with:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (allFriends.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            "No friends added yet",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: allFriends.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final friend = allFriends[index];
                            final isChecked = locationProvider.isFriendChecked(
                              friend.uid,
                              allFriendUids,
                            );

                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              value: isChecked,
                              activeColor: const Color.fromARGB(
                                255,
                                62,
                                143,
                                243,
                              ),
                              title: Text(
                                friend.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              secondary: CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  220,
                                  225,
                                  235,
                                ),
                                child: Text(
                                  friend.username.isNotEmpty
                                      ? friend.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              onChanged: (bool? value) {
                                locationProvider.toggleFriendSharing(
                                  friend.uid,
                                  allFriendUids,
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
          },
        );
      },
    );
  }
}
