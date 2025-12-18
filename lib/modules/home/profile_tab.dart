import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lmg_app/data/services/auth_service.dart';
import 'package:lmg_app/data/models/user.dart'; // Import your providers
import 'package:lmg_app/core/config/language_provider.dart';
import 'package:lmg_app/core/config/theme_provider.dart';
import 'package:lmg_app/core/localization/localization.dart';
import 'package:lmg_app/data/services/customer_ops_service.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileTab({super.key, required this.onLogout});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = true;
  bool _isEditing = false;
  User? _profileData;
  String? _error;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load local cached user first
      final localUser = await AuthService.getUser();
      if (mounted && localUser != null) {
        setState(() {
          _profileData = localUser;
          _updateControllers();
        });
      }

      // Fetch fresh from backend
      final apiData = await CustomerOpsService.getProfile();
      final fetchedUser = User.fromJson(apiData);

      if (mounted) {
        setState(() {
          _profileData = fetchedUser;
          _updateControllers();
        });
      }

      await AuthService.saveUser(fetchedUser);
    } catch (e) {
      if (mounted) setState(() => _error = "Failed to fetch profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateControllers() {
    if (_profileData == null) return;

    _fullNameController.text = _profileData!.fullName ?? "";
    _emailController.text = _profileData!.email;
    _phoneController.text = _profileData!.phonenumber?.toString() ?? "";
    _addressController.text = _profileData!.address ?? "";
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      if (mounted) setState(() => _profileImageFile = File(image.path));
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final res = await CustomerOpsService.updateProfile(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phonenumber: _phoneController.text,
        address: _addressController.text,
        profileImage: _profileImageFile,
      );

      // Backend returns: { message, updatedCustomer: {...} }
      final updatedUser = User.fromJson(res['updatedCustomer']);

      if (mounted) {
        setState(() {
          _profileData = updatedUser;
          _updateControllers();
          _isEditing = false;
          _profileImageFile = null;
        });
      }

      await AuthService.saveUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use Builder to get a context that is a descendant of MaterialApp
      // This is important for MyApp.setLocale and MyApp.setThemeMode to work correctly
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              widget.onLogout();
            },
          ),
        ],
      ),
      body: _isLoading && _profileData == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _fetchProfile, // Pull to refresh profile data
                  child: _buildProfileView(),
                ),
    );
  }

  Widget _buildProfileView() {
    final profileImageUrl = _profileData?.profilePictureUrl;
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language and Theme Switchers
          Row(
            children: [
              const Icon(Icons.language, size: 20, color: Colors.black87),
              const SizedBox(width: 6),
              DropdownButton<Locale>(
                value: Localizations.localeOf(context),
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    Provider.of<LanguageProvider>(context, listen: false).changeLocale(newLocale.languageCode);
                  }
                },
                items: AppLocalizations.supportedLocales.map((Locale locale) {
                  String languageName;
                  switch (locale.languageCode) {
                    case 'en': languageName = 'English'; break;
                    case 'am': languageName = 'አማርኛ'; break;
                    case 'om': languageName = 'Oromoo'; break;
                    default: languageName = locale.languageCode;
                  }
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(languageName, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.brightness_6, size: 20, color: Colors.black87),
              const SizedBox(width: 6),
              DropdownButton<ThemeMode>(
                value: Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
                underline: Container(), // Use Container() instead of SizedBox()
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (ThemeMode? newThemeMode) {
                  if (newThemeMode != null) {
                    Provider.of<ThemeProvider>(context, listen: false).setThemeMode(newThemeMode);
                  }
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System', style: TextStyle(fontSize: 14))),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light', style: TextStyle(fontSize: 14))),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark', style: TextStyle(fontSize: 14))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 0),
          Center(
            child: GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : (profileImageUrl != null ? NetworkImage(profileImageUrl) : null)
                        as ImageProvider?,
                child: _profileImageFile == null && profileImageUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(label: localizations.translate('full_name'), controller: _fullNameController),
          _buildTextField(label: localizations.translate('email'), controller: _emailController),
          _buildTextField(
            label: localizations.translate('phone'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(label: localizations.translate('address'), controller: _addressController),
          const SizedBox(height: 24),
          if (_isEditing)
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(localizations.translate('save_changes')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileViewOriginal() {
    final profileImageUrl = _profileData?.profilePictureUrl;
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageFile != null
                  ? FileImage(_profileImageFile!)
                  : (profileImageUrl != null ? NetworkImage(profileImageUrl) : null)
                      as ImageProvider?,
              child: _profileImageFile == null && profileImageUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField(label: 'Full Name', controller: _fullNameController),
          _buildTextField(label: 'Email', controller: _emailController),
          _buildTextField(
            label: 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(label: 'Address', controller: _addressController),

          const SizedBox(height: 24),

          if (_isEditing)
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: !_isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
