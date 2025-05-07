import 'package:chatapp/components/my_drawer.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/user_tile.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chat and Auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Fetch stored custom name
  Future<String?> _getSavedName(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(email);  // Return saved name or null
  }

  // Save custom name
  Future<void> _saveCustomName(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(email, name);
    setState(() {});  // Refresh UI after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0,top: 0,bottom: 4),
          child: Text(
            "Lets Chat",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // Build list of users except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error fetching users: ${snapshot.error}");
          return const Center(child: Text("Error fetching users"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Loading users...");
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print("No users found in Firestore.");
          return const Center(child: Text("No users found."));
        }

        print("User list received: ${snapshot.data}"); // Debug print

        return ListView(
          children: snapshot.data!
              .map<Widget>((userdata) => _buildUserListItem(userdata, context))
              .toList(),
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(Map<String, dynamic> userdata, BuildContext context) {
    String email = userdata["email"];

    return FutureBuilder<String?>(
      future: _getSavedName(email),  // Fetch saved name if available
      builder: (context, snapshot) {
        String displayName = snapshot.data ?? email;  // Show saved name or email

        return GestureDetector(
          onLongPress: () {
            // Open edit name dialog on long press
            _showEditNameDialog(context, email);
          },
          child: UserTile(
            text: displayName,
            onTap: () {
              // Open chat when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverEmail: email,
                    receiverID: userdata["uid"],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


  // Show dialog to edit user name
  void _showEditNameDialog(BuildContext context, String email) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Custom Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter a name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _saveCustomName(email, nameController.text); // Save name
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
