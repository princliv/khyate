import 'package:flutter/material.dart';
import 'package:khyate_b2b/screens/fitness_screen.dart';
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
          builder: (ctx, isDarkMode) => _HomeSection(
            title: 'Wellness Insights',
            description:
                'Mindfulness routines, nutrition advice, and daily rituals to keep you balanced.',
            isDarkMode: isDarkMode,
          ),
        ),
        AppShellPage(
          label: 'Liveness',
          icon: Icons.favorite,
          builder: (ctx, isDarkMode) => _HomeSection(
            title: 'Liveness Experiences',
            description:
                'Engage with vibrant communities, live sessions, and events curated for you.',
            isDarkMode: isDarkMode,
          ),
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
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1A2332);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroSection(
            isDarkMode: isDarkMode,
            title: 'Live Outside The Box',
            subtitle:
                'Boldly, creatively, and without limits. Join our movement for fitness, wellness, and vibrant community.',
            ctaText: 'Join the Movement',
            imageUrl:
                'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=1600&q=80',
            onCtaPressed: () {},
            lightModeTextColor: const Color(0xFF3B2A22),
            darkModeTextColor: const Color(0xFFF7F3EE),
            lightModeButtonColor: const Color(0xFF8F8377),
            lightModeButtonTextColor: const Color(0xFFF7F3EE),
            darkModeButtonColor: const Color(0xFFF7F3EE),
            darkModeButtonTextColor: const Color(0xFF1A1F2C),
            horizontalPadding: 24.0,
            maxContentWidth: 880,
          ),
          HomeStorySection(isDarkMode: isDarkMode),
          HomeLogoStorySection(isDarkMode: isDarkMode),
          HomeValuesSection(isDarkMode: isDarkMode),
          HomeCommunitySection(isDarkMode: isDarkMode),
        ],
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
