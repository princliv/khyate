import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final bool isDarkMode;
  final bool isAdmin;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final VoidCallback onShowAdminOptions;
  final VoidCallback onOpenProfile;

  const ComingSoonScreen({
    super.key,
    required this.isDarkMode,
    required this.isAdmin,
    required this.onLogout,
    required this.onToggleTheme,
    required this.onShowAdminOptions,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final Color cardColor =
        isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF1A2332);
    final Color secondaryTextColor =
        isDarkMode ? Colors.white70 : const Color(0xFF6B7280);
    final Color accentColor = const Color(0xFFEC4899);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Liveness',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              if (isAdmin) {
                onShowAdminOptions();
              } else {
                onOpenProfile();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
              color: Colors.white,
            ),
            tooltip: 'Toggle theme',
            onPressed: onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.favorite_rounded,
                        size: 18, color: Color(0xFFEC4899)),
                    SizedBox(width: 6),
                    Text(
                      'Liveness Experiences',
                      style: TextStyle(
                        color: Color(0xFFEC4899),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                          isDarkMode ? 0.4 : 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon circle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor,
                            const Color(0xFFA855F7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Liveness is coming soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We’re crafting live community events, pop-ups, and experiences that bring the Outbox energy into the real world.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ComingSoonPill(
                          icon: Icons.people_alt_rounded,
                          label: 'Community Gatherings',
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _ComingSoonPill(
                          icon: Icons.music_note_rounded,
                          label: 'Pop-up Events',
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Stay tuned — you’ll be the first to know when Liveness goes live.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill({
    required this.icon,
    required this.label,
    required this.isDarkMode,
  });

  final IconData icon;
  final String label;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final Color textColor =
        isDarkMode ? Colors.white70 : const Color(0xFF4B5563);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
        color: isDarkMode ? Colors.white10 : Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


