import 'package:flutter/material.dart';
import 'package:lmg_app/data/services/auth_service.dart';
import 'package:lmg_app/core/localization/localization.dart';
import 'package:lmg_app/modules/auth/login_tab.dart';
import 'home_tab.dart';
import '../booking/my_booking_page.dart';
import 'profile_tab.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   int _selectedIndex = 0;
  bool _isLoggedIn = false;
  List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkAuthStatus();

  }

  Future<void> _checkAuthStatus({bool navigateToHome = false}) async {
    final token = await AuthService.getToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;
        _buildTabs();
        if (navigateToHome && _isLoggedIn) {
          _selectedIndex = 0; // Navigate to HomeTab
        }
      });
    }
  }

  void _buildTabs() {
     _tabs = [
      HomeTab(onLoginTapped: () async => _onItemTapped(2)),
      MyBookingsPage(key: ValueKey<bool>(_isLoggedIn)), // Add a key to force rebuild on auth change
      _isLoggedIn
          ? ProfileTab(onLogout: () => _checkAuthStatus())
          : LoginTab(onLoginSuccess: () => _checkAuthStatus(navigateToHome: true)), 
    ];
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: _tabs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: localizations.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.book_online), label: localizations.translate('booking')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: _isLoggedIn ? localizations.translate('profile') : localizations.translate('login')),
        ],
      ),
    );
  }

}
