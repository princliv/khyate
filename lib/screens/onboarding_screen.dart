import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:flutter/cupertino.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController controller = PageController();
  int pageIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> pages = [
    {
      'headline': 'Welcome to\nOutbox Fitness',
      'subtitle':
          'Live Outside The Box — Boldly, creatively, and without limits. Join our movement for fitness, wellness, and vibrant community.',
      'icon': Icons.directions_run_rounded,
      'color': Color(0xFFFF6B6B),
      'bg': Color(0xFFFFF5F3),
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      'secondaryColor': Color(0xFFFF8E53),
    },
    {
      'headline': 'Dynamic Fitness',
      'subtitle':
          'From OUTSTEP to OUTMOVE, explore diverse fitness programs designed to challenge you and help you break free from routine.',
      'icon': Icons.fitness_center_rounded,
      'color': Color(0xFF3B82F6),
      'bg': Color(0xFFF0F7FF),
      'gradient': [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      'secondaryColor': Color(0xFF06B6D4),
    },
    {
      'headline': 'Mindful Wellness',
      'subtitle':
          'Nourish your body and mind with mindfulness routines, nutrition guidance, and daily rituals to keep you balanced and energized.',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF26C485),
      'bg': Color(0xFFF0FDF4),
      'gradient': [Color(0xFF26C485), Color(0xFF4ECDC4)],
      'secondaryColor': Color(0xFF4ECDC4),
    },
    {
      'headline': 'Vibrant Community',
      'subtitle':
          'Connect with like-minded individuals through live sessions, social events, and experiences that spark transformation and joy.',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFEC4899),
      'bg': Color(0xFFFFF1F9),
      'gradient': [Color(0xFFEC4899), Color(0xFFA855F7)],
      'secondaryColor': Color(0xFFA855F7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      pageIndex = index;
    });
    _fadeController.reset();
    _scaleController.reset();
    _slideController.reset();
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final pg = pages[pageIndex];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryColor = pg['color'] as Color;
    final secondaryColor = pg['secondaryColor'] as Color;

    return Scaffold(
      backgroundColor: pg['bg'] as Color,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated decorative background circles
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: Stack(
                children: [
                  Positioned(
                    top: -120,
                    right: -120,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.15),
                            primaryColor.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -180,
                    left: -180,
                    child: Container(
                      width: 450,
                      height: 450,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            secondaryColor.withOpacity(0.12),
                            secondaryColor.withOpacity(0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Additional small decorative circles
                  Positioned(
                    top: screenHeight * 0.15,
                    left: screenWidth * 0.1,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.4,
                    right: screenWidth * 0.15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  // Skip button at top - always visible
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 4.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: _onPageChanged,
                      itemCount: pages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, i) {
                        final page = pages[i];
                        return _buildPageContent(page, i == pageIndex);
                      },
                    ),
                  ),
                  // Page indicators
                  const SizedBox(height: 12),
                  _buildPageIndicators(),
                  const SizedBox(height: 36),
                  // Action buttons
                  _buildActionButton(pg),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page, bool isActive) {
    if (!isActive) {
      return const SizedBox.shrink();
    }

    final primaryColor = page['color'] as Color;
    final secondaryColor = page['secondaryColor'] as Color;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Icon container with gradient and enhanced shadow
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: (page['gradient'] as List<Color>),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner glow effect
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      page['icon'],
                      color: Colors.white,
                      size: 75,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              // Headline with gradient text effect
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: (page['gradient'] as List<Color>),
                ).createShader(bounds),
                child: Text(
                  page['headline'],
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              // Subtitle with improved readability
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  page['subtitle'],
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF1A2332).withOpacity(0.85),
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: pageIndex == i ? 36 : 10,
          height: 10,
          decoration: BoxDecoration(
            gradient: pageIndex == i
                ? LinearGradient(
                    colors: (pages[i]['gradient'] as List<Color>),
                  )
                : null,
            color: pageIndex == i
                ? null
                : Colors.grey.shade300.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: pageIndex == i
                ? [
                    BoxShadow(
                      color: (pages[i]['color'] as Color).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> pg) {
    final isLastPage = pageIndex == pages.length - 1;
    final buttonColor = pg['color'] as Color;
    final secondaryButtonColor = pg['secondaryColor'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: (pg['gradient'] as List<Color>),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: secondaryButtonColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isLastPage) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            } else {
              controller.nextPage(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
              );
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'Get Started' : 'Continue',
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                if (!isLastPage) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
