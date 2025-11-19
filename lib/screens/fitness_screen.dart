import 'package:flutter/material.dart';
import 'package:khyate_b2b/widgets/membership_carousel.dart';
import '../widgets/fitness_sessions_grid.dart';
import '../widgets/todays_classes_component.dart';
import '../widgets/membership_card.dart';

class FitnessScreen extends StatelessWidget {
  final bool isDarkMode;

  const FitnessScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final sessions = [
      FitnessSession(label: "OUTSTEP", icon: Icons.directions_run, onTap: () {}),
      FitnessSession(label: "OUTCORE", icon: Icons.accessibility_new, onTap: () {}),
      FitnessSession(label: "OUTMOVE", icon: Icons.fitness_center, onTap: () {}),
      FitnessSession(label: "OUTFIT", icon: Icons.pan_tool, onTap: () {}),
      FitnessSession(label: "OUTLIFT", icon: Icons.self_improvement, onTap: () {}),
      FitnessSession(label: "OUTRUSH", icon: Icons.timeline, onTap: () {}),
      FitnessSession(label: "OUTBEAT", icon: Icons.favorite, onTap: () {}),
    ];
    final List<MembershipCardData> memberships = [
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 32",
        title: "One Day Cardio",
        description: "one day evening cardio class by robert smith",
        time: "18:26 - 19:26",
        mentor: "w/ Robert Smith",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 12",
        title: "November Start With Yoga",
        description: "one day class for November.",
        time: "07:00 - 08:00",
        mentor: "w/ Sarah Lindsey",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 45",
        title: "December Program",
        description: "this program is for December classes",
        time: "10:00 - 11:00",
        mentor: "w/ Nick Mitchell",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 10",
        title: "25 Sep Class",
        description: "early morning 25 Sep class",
        time: "06:00 - 07:00",
        mentor: "w/ Sarah Lin",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1519864600361-7efb74e05aa0?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 22",
        title: "Morning Yoga Boost",
        description: "start your day right with yoga.",
        time: "08:00 - 09:00",
        mentor: "w/ Lisa Wong",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 25",
        title: "HIIT Express",
        description: "30 min intense HIIT session.",
        time: "17:00 - 17:30",
        mentor: "w/ Mike Kross",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 38",
        title: "Strength and Flex",
        description: "power and flexibility training.",
        time: "14:00 - 15:00",
        mentor: "w/ Anna Belle",
        reviews: "0 reviews",
      ),
      MembershipCardData(
        imageUrl: 'https://images.unsplash.com/photo-1477332552946-cfb384aeaf1c?auto=format&fit=crop&w=400&q=80',
        category: "FITNESS",
        price: "AED 18",
        title: "Evening Meditation",
        description: "relax and restore after work.",
        time: "19:00 - 20:00",
        mentor: "w/ Amit Patel",
        reviews: "0 reviews",
      ),
    ];
    final Color scaffoldBackground = isDarkMode 
    ? const Color(0xFF1A2332) 
    : const Color(0xFFFCEEE5);

    final Color headlineColor = isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF1A2332);
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 56),
            Text(
              "Discover the best in fitness & wellness",
              style: TextStyle(
                color: headlineColor,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            Text(
              "Your next workout, wellness class, or live session is just a click away",
              style: TextStyle(
                color: subTextColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search for anything",
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                  Container(
                    height: 48,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          // Location picker logic here
                        },
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Select location',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: MaterialButton(
                      color: Colors.red,
                      minWidth: 0,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, color: headlineColor),
                SizedBox(width: 8),
                Icon(Icons.android, color: headlineColor),
                SizedBox(width: 16),
                Text(
                  "Get the app today",
                  style: TextStyle(color: headlineColor),
                ),
              ],
            ),
            FitnessSessionsGrid(sessions: sessions,isDarkMode: isDarkMode),
            SizedBox(height: 28),
            TodaysClassesComponent(
              totalClasses: 27,
              dateString: "11-11-2025",
              hasPackage: false,
              onShowAllPressed: () {},
              onChoosePackagePressed: () {},
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Top Membership',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: headlineColor,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {}, // Show all logic
                  child: Text(
                    "Show all (46) →",
                    style: TextStyle(
                        color: const Color(0xFFFF6767),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: memberships.length,
                itemBuilder: (context, index) {
                  return MembershipCard(
                    data: memberships[index],
                    onTap: () {},
                  );
                },
              ),
            ),
            MembershipCarousel(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}