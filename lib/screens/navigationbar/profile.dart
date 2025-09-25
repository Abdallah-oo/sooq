import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color.fromARGB(129, 158, 158, 158),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            // Profile Header
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: CircleAvatar(
                radius: 48,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Placeholder image
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Zizo Mohamed', // Placeholder name
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'zizo.mohamed@example.com', // Placeholder email
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Menu List
            _buildProfileMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(179, 134, 134, 134),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
              icon: Icons.person_outline, title: 'Edit Profile', onTap: () {}),
          _buildMenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              onTap: () {}),
          _buildMenuTile(
              icon: Icons.location_on_outlined,
              title: 'My Addresses',
              onTap: () {}),
          _buildMenuTile(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuTile(
              icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
          _buildMenuTile(
              icon: Icons.logout,
              title: 'Logout',
              isLogout: true,
              onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.green),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}