import 'package:flutter/material.dart';
import 'package:the_social/widgets/list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function() onProfileTap;
  final void Function() onLogout;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              // home
              MyListTile(
                icon: Icons.home,
                text: "H O M E",
                onTap: () => Navigator.pop(context),
              ),

              // profile
              MyListTile(
                icon: Icons.person,
                text: "P R O F I L E",
                onTap: onProfileTap,
              ),
            ],
          ),

          // logout
          Padding(
            padding: const EdgeInsets.only(
              bottom: 25.0,
            ),
            child: MyListTile(
              icon: Icons.logout,
              text: "L O G O U T",
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}
