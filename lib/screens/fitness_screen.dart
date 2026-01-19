import 'package:Outbox/widgets/membership_carousel.dart';
import 'package:Outbox/widgets/todays_classes_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:khyate_b2b/widgets/membership_carousel.dart';
import '../widgets/fitness_sessions_grid.dart';
import '../widgets/todays_classes_component.dart';
import '../widgets/membership_card.dart';
import '../widgets/fitness_session_modal.dart';
import '../widgets/membership_modal.dart';
import '../models/membership_card_model.dart';
import '../services/notification_service.dart';
import '../services/subscription_service.dart';
import '../services/package_service.dart';
import '../services/trainer_service.dart';
import '../services/subscription_booking_service.dart';
import '../services/master_data_service.dart';

class FitnessScreen extends StatefulWidget {
  final bool isDarkMode;

  const FitnessScreen({super.key, required this.isDarkMode});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  String searchQuery = '';
  String? selectedTrainer;
  bool filterFutureDate = false;

  /// Session descriptions map
  static const Map<String, String> sessionDescriptions = {
    "OUTRUSH": "OutRush is a high-intensity, heart-pumping cardio class that takes you through intervals of explosive movements like sprints, jumps, and quick footwork. Designed for all fitness levels, this workout will challenge your endurance and leave you feeling exhilarated. Our energizing playlist and motivating coaches will push you past your limits — helping you torch serious calories and improve cardiovascular fitness. OutRush is offered in 30 or 45-minute sessions.",
    "OUTBEAT": "OutBeat is a rhythmic cardio workout that blends dance-inspired movements with easy-to-follow routines. Powered by upbeat tracks, this session is all about moving to the rhythm, boosting your stamina, and having fun. Perfect for anyone who loves music and dance, this feel-good class will leave you sweating, smiling, and energized. OutBeat is offered in 45 or 60-minute sessions.",
    "OUTSTEP": "OutStep is a step-based aerobics class that brings a classic workout into a new era. You’ll step up, down, and across the platform to the beat of motivating tunes. Designed for all fitness levels, this class enhances coordination, balance, and cardio fitness — all while toning your legs and glutes. OutStep is offered as a 30, 45, or 60-minute workout.",
    "OUTLIFT": "OutLift is a strength-training workout that targets every major muscle group using barbells, dumbbells, and bodyweight exercises. Our expert trainers will coach you through lifting techniques with the perfect mix of power and control. Get ready to build lean muscle, boost metabolism, and feel stronger every session. OutLift is offered in 45 or 60-minute sessions.",
    "OUTFIT": "OutFit is a functional fitness class designed to mimic real-life movements like pushing, pulling, and lifting. You’ll improve strength, endurance, mobility, and coordination using a mix of bodyweight exercises and light equipment. Every workout is different — keeping your body challenged and your fitness balanced. OutFit is offered as a 45 or 60-minute workout.",
    "OUTMOVE": "OutMove is a bodyweight training session where no equipment is required — just your energy and drive. Combining exercises like lunges, squats, planks, and mobility drills, this class is perfect for toning muscles, improving flexibility, and burning calories. It’s an accessible workout that can scale up or down for all fitness levels. OutMove is offered in 30 or 45-minute sessions.",
    "OUTCORE": "OutCore is a focused core-conditioning class that will help you build a strong, stable center. With exercises like planks, bridges, twists, and controlled movements, this session improves balance, posture, and overall functional strength. It’s short, sharp, and highly effective — making it a must-do addition to your fitness routine. OutCore is offered in 30-minute sessions.",
  };

  /// Session image paths map
  static const Map<String, String> sessionImages = {
    "OUTRUSH": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop&q=80",
    "OUTBEAT": "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&h=400&fit=crop&q=80",
    "OUTSTEP": "https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=800&h=400&fit=crop&q=80",
    "OUTLIFT": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&h=400&fit=crop&q=80",
    "OUTFIT": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=400&fit=crop&q=80",
    "OUTMOVE": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80",
    "OUTCORE": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80",
  };

  /// Get all trainers from your API
  Future<List<String>> getTrainers() async {
    try {
      final trainerService = TrainerService();
      final trainers = await trainerService.getAllTrainers();
      return trainers.map((trainer) {
        final firstName = trainer['first_name'] ?? '';
        final lastName = trainer['last_name'] ?? '';
        return '$firstName $lastName'.trim();
      }).where((name) => name.isNotEmpty).toList();
    } catch (e) {
      print('Error fetching trainers: $e');
      return [];
    }
  }

  /// Stream of membership cards from API
  /// Uses API endpoint 14.3: POST /api/v1/subscription/get-all-subscription
  /// Request body: {page: 1, limit: 50, categoryId: "fitness_category_id"}
  Stream<List<MembershipCardData>> getMembershipsStream() async* {
    try {
      final subscriptionService = SubscriptionService();
      final subscriptionBookingService = SubscriptionBookingService();
      final masterDataService = MasterDataService();
      
      // Fetch all categories to find fitness category and collect wellness categories
      final categories = await masterDataService.getAllCategories();
      String? fitnessCategoryId;
      List<String> wellnessCategoryIds = [];
      
      // Find fitness category by name (case-insensitive) and collect wellness categories
      for (var category in categories) {
        final categoryName = (category['cName'] ?? category['name'] ?? '').toString().toLowerCase().trim();
        final categoryId = (category['_id'] ?? category['id'] ?? '').toString();
        
        if (categoryName.isNotEmpty) {
          if (categoryName.contains('fitness') && !categoryName.contains('wellness')) {
            fitnessCategoryId = categoryId;
            print('Found fitness category: $categoryName with ID: $fitnessCategoryId');
          } else if (categoryName.contains('wellness')) {
            wellnessCategoryIds.add(categoryId);
            print('Found wellness category: $categoryName with ID: $categoryId');
          }
        }
      }
      
      if (fitnessCategoryId == null) {
        print('Warning: Fitness category not found. Will use client-side filtering.');
      }
      
      // API Endpoint: POST /api/v1/subscription/get-all-subscription
      // Body: {page, limit, categoryId, sessionTypeId, trainerId}
      final result = await subscriptionService.getAllSubscriptions(
        page: 1,
        limit: 100, // Increased to get more subscriptions
        categoryId: fitnessCategoryId, // Filter by fitness category if found
      );
      
      var subscriptions = result?['subscriptions'] ?? result?['data'] ?? [];
      
      print('Fitness Screen: Fetched ${subscriptions.length} subscriptions from API');
      
      // ALWAYS filter client-side as safety measure to ensure only fitness items appear
      // This handles cases where API filtering might not work correctly
      if (subscriptions.isNotEmpty) {
        subscriptions = subscriptions.where((sub) {
          final category = sub['categoryId'];
          if (category == null) return false;
          
          String categoryName = '';
          String categoryIdStr = '';
          
          // Handle category as Map (populated) or String/ObjectId
          if (category is Map) {
            categoryName = (category['name'] ?? category['cName'] ?? '').toString().toLowerCase().trim();
            categoryIdStr = (category['_id'] ?? category['id'] ?? '').toString();
          } else {
            categoryIdStr = category.toString();
          }
          
          // Explicitly exclude wellness categories by ID
          if (wellnessCategoryIds.isNotEmpty && wellnessCategoryIds.contains(categoryIdStr)) {
            print('Fitness Screen: Excluding subscription ${sub['name']} - wellness category ID: $categoryIdStr');
            return false;
          }
          
          // If category is just an ID, try to match with found category ID
          if (category is! Map) {
            if (fitnessCategoryId != null && categoryIdStr == fitnessCategoryId) {
              return true; // Match by ID if we found the fitness category
            }
            // If it's a wellness ID, exclude it
            if (wellnessCategoryIds.contains(categoryIdStr)) {
              return false;
            }
            // Can't determine from ID alone, skip it
            return false;
          }
          
          // Match by category name (case-insensitive)
          // Include fitness categories and exclude wellness
          if (categoryName.isEmpty) return false;
          
          // Explicitly exclude wellness
          if (categoryName.contains('wellness') || categoryName.contains('spa') || categoryName.contains('yoga')) {
            print('Fitness Screen: Excluding subscription ${sub['name']} - wellness category name: $categoryName');
            return false;
          }
          
          // Include only fitness
          final isFitness = categoryName.contains('fitness') || categoryName.contains('gym') || categoryName.contains('workout');
          
          // Also match by ID if we found the fitness category
          if (fitnessCategoryId != null && categoryIdStr == fitnessCategoryId) {
            return true;
          }
          
          return isFitness;
        }).toList();
        
        print('Fitness Screen: After filtering, ${subscriptions.length} fitness subscriptions remain');
      }
      
      // Fetch user's purchased subscriptions
      List<String> purchasedIds = [];
      try {
        final bookings = await subscriptionBookingService.getBookingHistory();
        purchasedIds = bookings.map((booking) {
          final subId = booking['subscriptionId'] ?? booking['subscription'];
          if (subId is Map) return subId['_id']?.toString() ?? subId['id']?.toString() ?? '';
          return subId?.toString() ?? '';
        }).where((id) => id.isNotEmpty).toList();
      } catch (e) {
        print('Error fetching purchased subscriptions: $e');
      }
      
      // Convert subscriptions to MembershipCardData
      final membershipCards = subscriptions.map<MembershipCardData>((sub) {
        final id = sub['_id']?.toString() ?? sub['id']?.toString() ?? '';
        final trainer = sub['trainer'];
        final trainerName = trainer is Map 
            ? '${trainer['first_name'] ?? ''} ${trainer['last_name'] ?? ''}'.trim()
            : trainer?.toString() ?? 'Unknown Trainer';
        
        final address = sub['Address'] is Map ? sub['Address'] : {};
        final location = address['location']?.toString() ?? 
                        address['addressLine1']?.toString() ?? 
                        'Location TBD';
        
        final dates = sub['date'];
        String dateStr = '';
        if (dates is List && dates.isNotEmpty) {
          dateStr = dates.first?.toString() ?? '';
        } else if (dates is String) {
          dateStr = dates;
        }
        
        final category = sub['categoryId'];
        String categoryName = 'Fitness';
        if (category is Map) {
          // Backend uses 'cName' field, but also check 'name' for compatibility
          categoryName = (category['cName'] ?? category['name'] ?? 'Fitness').toString();
          // Capitalize first letter for display
          if (categoryName.isNotEmpty) {
            categoryName = categoryName[0].toUpperCase() + categoryName.substring(1);
          }
        }
        
        return MembershipCardData(
          id: id,
          title: sub['name'] ?? 'Class',
          mentor: trainerName,
          date: dateStr,
          location: location,
          imageUrl: sub['media'] ?? sub['imageUrl'] ?? '',
          price: sub['price']?.toString() ?? '0',
          description: sub['description'] ?? '',
          category: categoryName,
          time: '${sub['startTime'] ?? ''} - ${sub['endTime'] ?? ''}',
          reviews: '0',
          isPurchased: purchasedIds.contains(id),
        );
      }).toList();
      
      yield membershipCards;
    } catch (e) {
      print('Error fetching memberships: $e');
      yield [];
    }
  }

  /// Filter memberships
  List<MembershipCardData> filterMemberships(List<MembershipCardData> list) {
    return list.where((card) {
      final matchesName = searchQuery.isEmpty || card.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesTrainer = selectedTrainer == null || card.mentor == selectedTrainer;
      final matchesDate = !filterFutureDate || DateTime.tryParse(card.date)?.isAfter(DateTime.now()) == true;
      return matchesName && matchesTrainer && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Brand Colors - Fitness (Teal: #21C8B1)
    final Color scaffoldBackground = widget.isDarkMode ? const Color(0xFF353535) : const Color(0xFFFCEEE5);
    final Color headlineColor = widget.isDarkMode ? const Color(0xFF21C8B1) : const Color(0xFF353535);
    final Color subTextColor = widget.isDarkMode ? const Color(0xFF99928D) : const Color(0xFF99928D);
    final Color accentColor = const Color(0xFF21C8B1); // Teal for Fitness
    
    // Brand Fonts
    final TextStyle headlineStyle = GoogleFonts.montserrat(
      fontSize: 38,
      fontWeight: FontWeight.bold,
      color: headlineColor,
    );
    final TextStyle bodyStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: subTextColor,
    );

    final sessions = [
      FitnessSession(
        label: "OUTSTEP",
        icon: Icons.directions_run,
        onTap: () => FitnessSessionModal.show(context, "OutStep", sessionDescriptions["OUTSTEP"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTSTEP"]),
      ),
      FitnessSession(
        label: "OUTCORE",
        icon: Icons.accessibility_new,
        onTap: () => FitnessSessionModal.show(context, "OutCore", sessionDescriptions["OUTCORE"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTCORE"]),
      ),
      FitnessSession(
        label: "OUTMOVE",
        icon: Icons.fitness_center,
        onTap: () => FitnessSessionModal.show(context, "OutMove", sessionDescriptions["OUTMOVE"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTMOVE"]),
      ),
      FitnessSession(
        label: "OUTFIT",
        icon: Icons.pan_tool,
        onTap: () => FitnessSessionModal.show(context, "OutFit", sessionDescriptions["OUTFIT"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTFIT"]),
      ),
      FitnessSession(
        label: "OUTLIFT",
        icon: Icons.self_improvement,
        onTap: () => FitnessSessionModal.show(context, "OutLift", sessionDescriptions["OUTLIFT"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTLIFT"]),
      ),
      FitnessSession(
        label: "OUTRUSH",
        icon: Icons.timeline,
        onTap: () => FitnessSessionModal.show(context, "OutRush", sessionDescriptions["OUTRUSH"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTRUSH"]),
      ),
      FitnessSession(
        label: "OUTBEAT",
        icon: Icons.favorite,
        onTap: () => FitnessSessionModal.show(context, "OutBeat", sessionDescriptions["OUTBEAT"]!, widget.isDarkMode,
            imagePath: sessionImages["OUTBEAT"]),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),

        child: Column(
          children: [
            const SizedBox(height: 56),
            Text(
              "Discover the best in fitness & wellness",
              style: headlineStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              "Your next workout, wellness class, or live session is just a click away",
              style: bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            /// SEARCH BAR WITH FILTERS
            Container(
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) => setState(() => searchQuery = value),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search by name",
                            hintStyle: GoogleFonts.inter(
                              color: widget.isDarkMode ? Colors.white54 : Colors.grey,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            color: widget.isDarkMode ? Colors.white : const Color(0xFF353535),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() {}),
                        icon: Icon(Icons.search, color: accentColor),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<List<String>>(
                          future: getTrainers(),
                          builder: (context, snapshot) {
                            final trainers = snapshot.data ?? [];
                            return DropdownButton<String>(
                              hint: Text(
                                "Select Trainer",
                                style: GoogleFonts.inter(),
                              ),
                              value: selectedTrainer,
                              isExpanded: true,
                              items: trainers
                                  .map((trainer) => DropdownMenuItem(
                                        value: trainer,
                                        child: Text(
                                          trainer,
                                          style: GoogleFonts.inter(),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => selectedTrainer = value);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: filterFutureDate,
                        onChanged: (value) => setState(() => filterFutureDate = value!),
                      ),
                      Text(
                        "Future Dates",
                        style: GoogleFonts.inter(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            /// APP ICONS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                      Icon(Icons.apple, color: headlineColor),
                      const SizedBox(width: 8),
                      Icon(Icons.android, color: headlineColor),
                      const SizedBox(width: 16),
                      Text(
                        "Get the app today",
                        style: GoogleFonts.inter(
                          color: headlineColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),

            const SizedBox(height: 28),
            FitnessSessionsGrid(sessions: sessions, isDarkMode: widget.isDarkMode),
const SizedBox(height: 28),
TodaysClassesList(isDarkMode: widget.isDarkMode),
const SizedBox(height: 92),


            /// TOP MEMBERSHIP SECTION
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Top Membership',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: headlineColor,
                  ),
                ),
              ),
            ),

            /// FILTERED TOP MEMBERSHIP CARDS
            StreamBuilder<List<MembershipCardData>>(
              stream: getMembershipsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No memberships available",
                      style: GoogleFonts.inter(color: subTextColor),
                    ),
                  );
                }

                final allMemberships = snapshot.data!;
                NotificationService.scheduleUpcomingSessions(allMemberships);
                final memberships = filterMemberships(allMemberships);

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: memberships
                        .map(
                          (card) => MembershipCard(
                            data: card,
                            onTap: () {
                              MembershipModal.show(context, card, widget.isDarkMode);
                            },
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            /// FIND YOUR NEW LATEST PACKAGES SECTION
            MembershipCarousel(
              searchQuery: searchQuery,
              selectedTrainer: selectedTrainer,
              filterFutureDate: filterFutureDate,
              isDarkMode: widget.isDarkMode,
              categoryFilter: 'fitness', // Only show fitness packages
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
