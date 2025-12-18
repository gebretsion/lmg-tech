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
    if (mounted && _isLoggedIn != (token != null)) {
      setState(() => _isLoggedIn = token != null);
    }
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
    final screen = MediaQuery.of(context).size;
    final isSmallScreen = screen.width < 360;

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
          padding: EdgeInsets.symmetric(horizontal: screen.width * 0.04, vertical: 5),
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

              // Welcome title - Responsive Font Size
              Text(
                "Welcome to LMG Tech",
                style: TextStyle(
                  fontSize: screen.width * 0.065, // Responsive font size
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
                  hintText: localizations.translate('search_hint'), // This will update on rebuild
                  hintStyle: TextStyle(color: const Color.fromARGB(222, 117, 117, 117), fontSize: screen.width * 0.035),
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
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: RichText(
                        key: ValueKey(localizations.locale), // Add a key to trigger the animation
                        text: TextSpan(
                          style: TextStyle(fontSize: screen.width * 0.032, color: Color(0xFF0D47A1), height: 1.5),
                          children: [
                            TextSpan(text: "${localizations.translate('Browsing as Guest')}. "),
                            TextSpan(
                              text: localizations.translate('login'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Color(0xFF1976D2),
                                fontSize: screen.width * 0.038,
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
                  ),
                ),

              const SizedBox(height: 15),

              // Responsive Category Grid (2 x 2)
              GridView.builder(
                  shrinkWrap: true, // Important for GridView inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Disable grid's own scrolling
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isSmallScreen ? 0.9 : 1.0, // Adjust aspect ratio for smaller screens
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
                            Icon(cat['icon'], size: screen.width * 0.09, color: const Color.fromARGB(255, 7, 116, 225)),
                            const SizedBox(height: 14),
                            
                            Text(
                              cat['name']
                                  .replaceAllMapped(
                                      RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                                  .trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Adjusted for better fit
                                color: Color.fromARGB(221, 8, 106, 219),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
    final isOtherCategory = selectedCategory == 'Other';

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            selectedCategory ?? localizations.translate('properties'),
            key: ValueKey(selectedCategory ?? localizations.locale.languageCode),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedCategory = null;
              properties = [];
              _searchController.clear();
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
              : isOtherCategory
                  ? _buildGroupedPropertiesList()
                  : _buildStandardPropertiesList(),
    );
  }

  Widget _buildStandardPropertiesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return _buildPropertyCard(properties[index]);
      },
    );
  }

  Widget _buildGroupedPropertiesList() {
    final localizations = AppLocalizations.of(context);
    final Map<String, List<Property>> groupedProperties = {};

    for (var prop in properties) {
      final subCategory = prop.subCategory?.trim();
      final key = (subCategory == null || subCategory.isEmpty)
          ? localizations.translate('uncategorized')
          : subCategory;
      (groupedProperties[key] ??= []).add(prop);
    }

    final subCategoryKeys = groupedProperties.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: subCategoryKeys.length,
      itemBuilder: (context, index) {
        final subCategory = subCategoryKeys[index];
        final propsInSubCategory = groupedProperties[subCategory]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Text(
                subCategory,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            ...propsInSubCategory.map((prop) => _buildPropertyCard(prop)),
          ],
        );
      },
    );
  }

  Widget _buildPropertyCard(Property property) {
    final localizations = AppLocalizations.of(context);
    return PropertyCard(
      property: property,
      onDetailTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailPage(property: property),
          ),
        );
      },
      onBookNowTap: () async {
        final token = await AuthService.getToken();
        if (token == null) {
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
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage(property: property)));
                    },
                  ),
                  TextButton(
                    child: Text(localizations.translate('login')),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(property: property)));
                    },
                  ),
                ],
              );
            },
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PropertyBookingPage(property: property)),
          );
        }
      },
    );
  }
}
