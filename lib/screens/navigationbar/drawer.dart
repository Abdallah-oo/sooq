import 'package:flutter/material.dart';

class Customdrawer extends StatelessWidget {
  const Customdrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'More Options',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          children: [
            _buildSection(
              
              title: 'My Account',
              items: [
                _buildMenuTile(
                  icon: Icons.person_outline,
                  iconColor: Colors.blue,
                  title: 'My Profile',
                  onTap: () {
                    // Navigate to Profile Page
                  },
                ),
                _buildMenuTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: Colors.orange,
                  title: 'My Orders',
                  onTap: () {},
                ),
                _buildMenuTile(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.purple,
                  title: 'My Addresses',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
          
              title: 'App Settings',
              items: [
                _buildMenuTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.red,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildMenuTile(
                  icon: Icons.language_outlined,
                  iconColor: Colors.teal,
                  title: 'Language',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              
              title: 'Support',
              items: [
                _buildMenuTile(
                  icon: Icons.headset_mic_outlined,
                  iconColor: Colors.green,
                  title: 'Customer Service',
                  onTap: () {},
                ),
                _buildMenuTile(
                  icon: Icons.policy_outlined,
                  iconColor: Colors.grey,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _buildMenuTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.indigo,
                  title: 'About Us',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMenuTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Logout',
              isLogout: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection( {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required Color iconColor, required String title, required VoidCallback onTap, bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Color.lerp(Colors.white, iconColor, 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isLogout ? Colors.red : Colors.black87)),
      trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
    