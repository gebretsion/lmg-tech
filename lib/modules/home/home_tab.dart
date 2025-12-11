import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../data/services/customer_ops_service.dart';
import '../../data/services/auth_service.dart';
import '../../core/localization/localization.dart';
import '../../data/models/property.dart';
import 'property_detail_page.dart';
import '../booking/property_booking_page.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../../widgets/cards/property_card.dart';
import 'package:provider/provider.dart';
import '../../core/config/language_provider.dart';

class HomeTab extends StatefulWidget {
  final Future<void> Function()? onLoginTapped;

  const HomeTab({super.key, this.onLoginTapped});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> categories = [
    {'name': 'EventSupply', 'icon': Icons.celebration},
    {'name': 'ConstructionEquipment', 'icon': Icons.construction},
    {'name': 'HealthcareMedical', 'icon': Icons.medical_services},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  String? selectedCategory;
  bool loading = false;
  List<Property> properties = [];
  bool _isLoggedIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthService.getToken();
    setState(() => _isLoggedIn = token != null);
  }

  void searchProperties(String category) async {
    setState(() => loading = true);

    try {
      final res = await CustomerOpsService.getPropertiesByCategory(category);
      final List<dynamic> props = res['properties'] ?? [];

      final parsedProperties = props
          .whereType<Map<String, dynamic>>()
          .map((p) => Property.fromJson(p))
          .toList();

      setState(() => properties = parsedProperties);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('could_not_fetch_properties'),
          ),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void searchPropertiesByName(String name) async {
    if (name.trim().isEmpty) {
      return;
    }
    setState(() {
      loading = true;
      // Use a generic title for search results
      selectedCategory = AppLocalizations.of(context).translate('search_results');
    });

    try {
      // Assuming a service method to search properties by name exists.
      // If not, this would need to be implemented in your CustomerOpsService.
      final res = await CustomerOpsService.getPropertiesByName(name);
      final List<dynamic> props = res['properties'] ?? [];

      final parsedProperties =
          props.whereType<Map<String, dynamic>>().map((p) => Property.fromJson(p)).toList();

      setState(() => properties = parsedProperties);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching properties: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedCategory == null
        ? _buildMainHome()
        : _buildPropertiesList();
  }

  // -------------------------------------------------------------
  // MAIN HOME SCREEN — UPDATED TO MATCH THE STITCH UI
  // -------------------------------------------------------------
  Widget _buildMainHome() {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Language mapping helper
    String getLanguageName(Locale locale) {
      switch (locale.languageCode) {
        case 'en':
          return 'English';
        case 'am':
          return 'አማርኛ';
        case 'om':
          return 'Oromoo';
        default:
          return '';
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Language selector (right aligned)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.language, size: 20, color: Colors.black87),
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
                      return DropdownMenuItem<Locale>(
                        value: locale,
                        child: Text(
                          getLanguageName(locale),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 1),

              // Welcome title
              Text(
                "Welcome to LMG Tech",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  
                ),
              ),

              const SizedBox(height: 15),

              // Search bar
              TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  searchPropertiesByName(value);
                },
                decoration: InputDecoration(
                  hintText: localizations.translate('search_hint'),
                  hintStyle: TextStyle(color: const Color.fromARGB(222, 117, 117, 117), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 149, 162, 237)),
                  filled: true,
                  fillColor: const Color.fromARGB(246, 212, 210, 227), // Missing closing bracket was here
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Guest info box
              if (!_isLoggedIn)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // A soft blue color
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0D47A1), height: 1.5),
                      children: [
                        TextSpan(text: "${localizations.translate('Browsing as Guest')}. "),
                        TextSpan(
                          text: localizations.translate('login'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Color(0xFF1976D2),
                            fontSize: 15,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (widget.onLoginTapped != null) {
                                await widget.onLoginTapped!();
                                _checkAuth();
                              }
                            },
                        ),
                        TextSpan(text: " ${localizations.translate('for full access')}."),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              // Category Grid (2 x 2)
              SizedBox(
                height: 280, 
              // Adjust this height to make containers smaller
                child: GridView.builder(
              
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final cat = categories[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        setState(() => selectedCategory = cat['name']);
                        searchProperties(cat['name']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 246, 246, 246),
                          borderRadius: BorderRadius.circular(15),
                          
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'], size: 35, color: const Color.fromARGB(255, 7, 116, 225)),
                            const SizedBox(height: 14),
                            
                            Text(
                              cat['name']
                                  .replaceAllMapped(
                                      RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                                  .trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color.fromARGB(221, 8, 106, 219),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PROPERTIES LIST SCREEN
  // -------------------------------------------------------------
  Widget _buildPropertiesList() {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory ?? localizations.translate('properties')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedCategory = null;
              properties = [];
            });
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? Center(
                  child: Text(localizations.translate('no_properties_available')),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(
                      property: properties[index],
                      onDetailTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailPage(
                              property: properties[index],
                            ),
                          ),
                        );
                      },
                      onBookNowTap: () async {
                        final token = await AuthService.getToken();
                        if (token == null) {
                          // User is not logged in, show login/register dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(localizations.translate('authentication_required')),
                                content: Text(localizations.translate('auth_required_message')),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(localizations.translate('register')),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage(property: properties[index])));
                                    },
                                  ),
                                  TextButton(
                                    child: Text(localizations.translate('login')),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(property: properties[index])));
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // User is logged in, proceed to booking
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PropertyBookingPage(property: properties[index])),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
