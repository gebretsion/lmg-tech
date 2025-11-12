import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map profile = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    setState(() => loading = true);

    try {
      final res = await AuthService.getProfile(); // no token passed
      setState(() {
        profile = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch profile')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage(profile['profilePictureUrl'] ?? ''),
                ),
                const SizedBox(height: 16),
                Text(
                  profile['fullName'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(profile['email'] ?? ''),
                Text(profile['phonenumber']?.toString() ?? ''),
                Text(profile['address'] ?? ''),
              ],
            ),
          );
  }
}
