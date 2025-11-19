import 'package:flutter/material.dart';
import 'package:khyate_b2b/screens/profile_screen.dart';

typedef AppShellPageBuilder = Widget Function(BuildContext context, bool isDarkMode);

class AppShellPage {
  const AppShellPage({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final AppShellPageBuilder builder;
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.pages,
    required this.onLogout,
    this.initialIndex = 0,
    this.landingBuilder,
  }) : assert(pages.length >= 1, 'Provide at least one page to AppShell');

  final List<AppShellPage> pages;
  final Future<void> Function() onLogout;
  final int initialIndex;
  final AppShellPageBuilder? landingBuilder;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const Color _barColor = Color(0xFF111827);

  late int _selectedIndex;
  late bool _hasNavSelection;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.pages.length - 1);
    _hasNavSelection = widget.landingBuilder == null;
  }

  void _onToggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _onNavTapped(int index) {
    if (_hasNavSelection && index == _selectedIndex) return;
    setState(() {
      _hasNavSelection = true;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color scaffoldBackground =
        _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFEFCF8);
    final bool showSelection = _hasNavSelection;

    final Widget displayedPage = showSelection
        ? widget.pages[_selectedIndex].builder(context, _isDarkMode)
        : widget.landingBuilder!(context, _isDarkMode);
    final Widget currentPage = KeyedSubtree(
      key: ValueKey(
        '${showSelection ? 'page_$_selectedIndex' : 'landing'}_${_isDarkMode ? 'dark' : 'light'}',
      ),
      child: displayedPage,
    );

    return Scaffold(
      key: ValueKey(
        '${showSelection ? 'page_$_selectedIndex' : 'landing'}_${_isDarkMode ? 'dark' : 'light'}',
      ),
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: _barColor,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/company.png', height: 32, width: 32),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        actions: [
  IconButton(
    icon: const Icon(Icons.person, color: Colors.white),
    tooltip: 'Profile',
    onPressed: () {
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProfileScreen(isDarkMode: _isDarkMode),
  ),
);


    },
  ),

  IconButton(
    icon: const Icon(Icons.logout, color: Colors.white),
    tooltip: 'Logout',
    onPressed: () async {
      await widget.onLogout();
    },
  ),

  IconButton(
    icon: Icon(
      _isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
      color: Colors.white,
    ),
    tooltip: 'Toggle theme',
    onPressed: _onToggleTheme,
  ),

  const SizedBox(width: 8),
],

      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: currentPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _barColor,
        selectedItemColor: showSelection ? Colors.amberAccent : Colors.white70,
        unselectedItemColor: Colors.white70,
        selectedIconTheme: showSelection
            ? const IconThemeData(color: Colors.amberAccent)
            : const IconThemeData(color: Colors.white70),
        selectedLabelStyle:
            showSelection ? null : const TextStyle(color: Colors.white70),
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: widget.pages
            .map(
              (page) => BottomNavigationBarItem(
                icon: Icon(page.icon),
                label: page.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
