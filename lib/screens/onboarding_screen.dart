import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:flutter/cupertino.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int pageIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'headline': 'Admin Excellence',
      'subtitle': 'Verify, analyze, and resolve—powerful tools for seamless B2B tailoring governance.',
      'icon': Icons.admin_panel_settings_rounded,
      'color': Color(0xFFC5A572),
      'bg': Color(0xFFF3EDE4),
    },
    {
      'headline': 'Tailor Empowerment',
      'subtitle': 'Showcase expertise, manage custom orders, chat live, plan resources, and boost business.',
      'icon': CupertinoIcons.scissors,
      'color': Color(0xFF2D7D7A),
      'bg': Color(0xFFF8F6F1),
    },
    {
      'headline': 'Customer Delight',
      'subtitle': 'Discover tailors, track orders, compare styles, AR previews, and share your look.',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF7F500C),
      'bg': Color(0xFFF3EDE4),
    },
    {
      'headline': 'UAE Heritage, Digital Future',
      'subtitle': 'Culturally inspired, AI-powered B2B platform for the next era of traditional dress.',
      'icon': Icons.flag_rounded,
      'color': Color(0xFFC5A572),
      'bg': Color(0xFFF8F6F1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pg = pages[pageIndex];
    return Scaffold(
      backgroundColor: pg['bg'] as Color,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (i) => setState(() => pageIndex = i),
                itemCount: pages.length,
                itemBuilder: (_, i) {
                  final page = pages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: page['color'],
                        radius: 55,
                        child: Icon(page['icon'], color: Colors.white, size: 56),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        page['headline'],
                        style: TextStyle(
                          fontSize: 22,
                          color: page['color'],
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        page['subtitle'],
                        style: const TextStyle(fontSize: 16, color: Color(0xFF1A2332)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: pageIndex == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pageIndex == i
                        ? (pages[i]['color'] as Color)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pg['color'],
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (pageIndex == pages.length - 1) {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
                } else {
                  controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.ease);
                }
              },
              child: Text(
                pageIndex == pages.length - 1 ? 'Get Started' : 'Next',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (pageIndex < pages.length - 1)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Skip', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}
