import 'package:flutter/material.dart';
import 'package:khyate_b2b/screens/cart_screen.dart';
import 'package:khyate_b2b/screens/fitness_screen.dart';
import 'package:khyate_b2b/screens/wellness_screen.dart';
import '../services/auth_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/hero_section.dart';
import '../widgets/section_card.dart';
import 'home/components/home_story_section.dart';
import 'home/components/home_logo_story_section.dart';
import 'home/components/home_values_section.dart';
import 'home/components/home_community_section.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      onLogout: () => _handleLogout(context),
      landingBuilder: (ctx, isDarkMode) => _HomeLanding(isDarkMode: isDarkMode),
      pages: [
        AppShellPage(
          label: 'Fitness',
          icon: Icons.fitness_center,
          builder: (ctx, isDarkMode) => FitnessScreen(isDarkMode: isDarkMode),
        ),
          AppShellPage(
    label: 'Wellness',
    icon: Icons.spa,
    builder: (ctx, isDarkMode) => WellnessScreen(isDarkMode: isDarkMode),
  ),
        AppShellPage(
          label: 'Cart',
          icon: Icons.shopping_cart_checkout_rounded,
         builder: (ctx,  isDarkMode) => CartScreen(isDarkMode: isDarkMode),
        ),
      ],
    );
  }
}

class _HomeLanding extends StatelessWidget {
  const _HomeLanding({required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8F9FA);
    final Color cardColor = isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1A2332);
    final Color secondaryTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF1A2332).withOpacity(0.7);
    final Color accentColor = const Color(0xFF20C8B1);

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          accentColor.withOpacity(0.1),
                          Colors.white,
                        ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live Outside The Box',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Access Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Fitness',
                          subtitle: 'Dynamic Classes',
                          color: const Color(0xFFFF6B6B),
                          gradient: const [
                            Color(0xFFFF6B6B),
                            Color(0xFFFF8E53),
                          ],
                          onTap: () {
                            AppShell.navigateToTab(context, 0);
                          },
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Icons.spa_rounded,
                          title: 'Wellness',
                          subtitle: 'Mind & Body',
                          color: const Color(0xFF26C485),
                          gradient: const [
                            Color(0xFF26C485),
                            Color(0xFF4ECDC4),
                          ],
                          onTap: () {
                            AppShell.navigateToTab(context, 1);
                          },
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessCard(
                    icon: Icons.favorite_rounded,
                    title: 'Liveness',
                    subtitle: 'Community & Events',
                    color: const Color(0xFFEC4899),
                    gradient: const [
                      Color(0xFFEC4899),
                      Color(0xFFA855F7),
                    ],
                    onTap: () {
                      AppShell.navigateToTab(context, 2);
                    },
                    isDarkMode: isDarkMode,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),

            // Today's Highlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Highlights",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '12',
                      label: 'Active Streak',
                      color: const Color(0xFFFF6B6B),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today_rounded,
                      value: '24',
                      label: 'This Week',
                      color: const Color(0xFF3B82F6),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      value: '4.8',
                      label: 'Rating',
                      color: const Color(0xFFFFD700),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Featured Session
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _FeaturedSessionCard(
                title: 'Morning Yoga Flow',
                instructor: 'Sarah Lindsey',
                time: '07:00 AM',
                imageUrl:
                    'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80',
                isDarkMode: isDarkMode,
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.search_rounded,
                          label: 'Find Classes',
                          color: accentColor,
                          isDarkMode: isDarkMode,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.bookmark_rounded,
                          label: 'Saved',
                          color: const Color(0xFFEC4899),
                          isDarkMode: isDarkMode,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.history_rounded,
                          label: 'History',
                          color: const Color(0xFF3B82F6),
                          isDarkMode: isDarkMode,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Our Values Section (Condensed App Version)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Values',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The foundation of everything we do',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _ValueCardApp(
                          title: 'Courage',
                          subtitle: 'Step beyond comfort zones',
                          icon: Icons.whatshot_rounded,
                          color: const Color(0xFFFF6B6B),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _ValueCardApp(
                          title: 'Creativity',
                          subtitle: 'Innovation in every way',
                          icon: Icons.lightbulb_rounded,
                          color: const Color(0xFF3B82F6),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _ValueCardApp(
                          title: 'Community',
                          subtitle: 'Connection and support',
                          icon: Icons.people_rounded,
                          color: const Color(0xFF26C485),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _ValueCardApp(
                          title: 'Authenticity',
                          subtitle: 'Genuine expression',
                          icon: Icons.verified_rounded,
                          color: const Color(0xFFEC4899),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _ValueCardApp(
                          title: 'Empowerment',
                          subtitle: 'Own your journey',
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFFFFD700),
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About Section (Condensed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Outbox',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Live Outside The Box',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We design unique experiences across fitness, wellness, and community gatherings, empowering individuals to break free from routine and express their authentic selves.',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PillChip(label: 'Fitness', color: accentColor),
                        _PillChip(label: 'Wellness', color: const Color(0xFF26C485)),
                        _PillChip(label: 'Community', color: const Color(0xFFEC4899)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Value Card for App Version
class _ValueCardApp extends StatelessWidget {
  const _ValueCardApp({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white;
    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF1A2332);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Pill Chip Widget
class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Quick Access Card Widget
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
    required this.onTap,
    required this.isDarkMode,
    this.isFullWidth = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDarkMode,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white;
    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF1A2332);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Featured Session Card Widget
class _FeaturedSessionCard extends StatelessWidget {
  const _FeaturedSessionCard({
    required this.title,
    required this.instructor,
    required this.time,
    required this.imageUrl,
    required this.isDarkMode,
  });

  final String title;
  final String instructor;
  final String time;
  final String imageUrl;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white;
    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF1A2332);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  instructor,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Join Now',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF20C8B1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Action Button Widget
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white;
    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF1A2332);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.description,
    required this.isDarkMode,
  });

  final String title;
  final String description;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1A2332);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore our curated programs that focus on your holistic growth.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 32),
          SectionCard(
            title: title,
            description: description,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
