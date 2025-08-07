// lib/pages/HomePage.dart
import 'package:diseas_discover/pages/LoginPage.dart';
import 'package:diseas_discover/pages/RegisterPage.dart';
import 'package:diseas_discover/services/classification_service.dart';
import 'package:diseas_discover/pages/analysis_tab_page.dart';
import 'package:diseas_discover/pages/results_tab_page.dart';
import 'package:diseas_discover/pages/guidance_tab_page.dart';
import 'package:diseas_discover/pages/saved_results_page.dart';
import 'package:diseas_discover/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ClassificationService _classificationService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 0;
  late List<Widget> _pages;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });

    _classificationService = ClassificationService();
    // Use the listener specifically for navigation
    _classificationService.addListener(_handleServiceUpdatesForNavigation);
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      AnalysisTabPage(classificationService: _classificationService),
      ResultsTabPage(
        classificationService: _classificationService,
        onNavigateToGuidance: () => _onItemTapped(2),
        onNavigateToLogin: _navigateToLoginPage,
        onNavigateToRegister: _navigateToRegisterPage,
      ),
      GuidanceTabPage(classificationService: _classificationService),
    ];
  }

  // --- THIS IS THE RESTORED LOGIC ---
  // This function now automatically navigates to the results tab.
  void _handleServiceUpdatesForNavigation() {
    if (!mounted) return;

    final service = _classificationService;
    // Check if the service just finished loading
    final justFinishedLoadingWithOutcome = !service.isLoading &&
        (service.predictedClass != null || service.error != null);

    // If we were on the Analysis tab (index 0) and the analysis just finished...
    if (justFinishedLoadingWithOutcome && _selectedIndex == 0) {
      // ...then automatically switch to the Results tab (index 1).
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  @override
  void dispose() {
    // Make sure to remove the correct listener
    _classificationService.removeListener(_handleServiceUpdatesForNavigation);
    _classificationService.dispose();
    super.dispose();
  }

  // ... (The rest of the HomePage code remains exactly the same)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToLoginPage() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LoginPage()))
        .then((_) => _checkCurrentUser());
  }

  void _navigateToRegisterPage() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) =>  Register()))
        .then((_) => _checkCurrentUser());
  }

  void _navigateToSavedResultsPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SavedResultsPage()));
  }

  void _checkCurrentUser() {
    if (mounted) {
      setState(() {
        _currentUser = _auth.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تشخيص الامراض الجلدية"),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.photo),
            label: 'تحليل',
            activeIcon: Icon(CupertinoIcons.photo_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'النتائج',
            activeIcon: Icon(CupertinoIcons.chart_bar_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bubble_left_bubble_right),
            label: 'إرشادات',
            activeIcon: Icon(CupertinoIcons.bubble_left_bubble_right_fill),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.7),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        elevation: 4.0,
        selectedFontSize: 13,
        unselectedFontSize: 12,
      ),
      endDrawer: _buildEndDrawer(),
    );
  }

  Widget _buildEndDrawer() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    String displayName = _currentUser?.displayName ?? "زائر";
    String email = _currentUser?.email ?? "يرجى تسجيل الدخول";
    String initial =
        _currentUser != null && displayName.isNotEmpty && displayName != "زائر"
            ? displayName[0].toUpperCase()
            : "Z";

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: Text(
              displayName,
              style: textTheme.titleLarge?.copyWith(color: AppColors.white),
            ),
            accountEmail: Text(
              email,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.white.withOpacity(0.8)),
            ),
            currentAccountPictureSize: const Size.square(60),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: Text(initial,
                  style: textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          if (_currentUser != null) ...[
            _drawerListTile(CupertinoIcons.person_fill, 'الملف الشخصي', () {}),
            _drawerListTile(CupertinoIcons.square_list_fill, 'نتائجي المحفوظة',
                _navigateToSavedResultsPage),
          ],
          const Divider(),
          if (_currentUser == null) ...[
            _drawerListTile(CupertinoIcons.square_arrow_left, 'تسجيل الدخول',
                _navigateToLoginPage,
                color: AppColors.success),
            _drawerListTile(CupertinoIcons.person_add_solid, 'إنشاء حساب',
                _navigateToRegisterPage,
                color: theme.colorScheme.primary),
          ] else ...[
            _drawerListTile(CupertinoIcons.square_arrow_right, 'تسجيل الخروج',
                () async {
              await _classificationService.logout();
            }, color: theme.colorScheme.error),
          ]
        ],
      ),
    );
  }

  ListTile _drawerListTile(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.iconTheme.color;
    final textColor = color ?? theme.textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
