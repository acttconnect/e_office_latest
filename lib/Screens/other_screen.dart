import 'package:e_office/Screens/Leaves_Screens/apply_leaves.dart';
import 'package:e_office/Screens/Profile_Screens/editprofile_screen.dart';
import 'package:e_office/Screens/Profile_Screens/userprofile_screen.dart';
import 'package:e_office/Screens/nomination_screen.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light grey background for better contrast
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
          },
        ),
        titleSpacing: 0,
        title: Text('Other Options', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Color(0xFF4769B2), // Consistent app theme color
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: ListView(
            children: [
              _buildListItem(
                context,
                title: 'Profile',
                assetPath: 'assets/images/profile.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileView()),
                  );
                },
              ),
              _buildListItem(
                context,
                title: 'Leaves',
                assetPath: 'assets/images/leaves.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaveManagementForm()),
                  );
                },
              ),
              _buildListItem(
                context,
                title: 'Nomination Form',
                assetPath: 'assets/images/nominee.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NominationForm()),
                  );
                },
              ),
              // Add more ListTiles here as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, {
    required String title,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage(assetPath),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
        onTap: onTap,
      ),
    );
  }
}
