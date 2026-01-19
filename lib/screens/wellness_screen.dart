import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/services/review_service.dart';
import 'package:Outbox/services/subscription_service.dart';
import 'package:Outbox/services/master_data_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:khyate_b2b/models/cart_model.dart';
// import 'package:khyate_b2b/providers/cart_provider.dart';
// import 'package:khyate_b2b/services/purchase_status_service.dart';
// import 'package:khyate_b2b/widgets/review_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/fitness_sessions_grid.dart';
import '../widgets/fitness_session_modal.dart';
import '../widgets/wellness_modal.dart';
import '../widgets/membership_carousel.dart';
import '../widgets/membership_card.dart';
import '../widgets/membership_modal.dart';
import '../widgets/todays_classes_list.dart';
import '../models/membership_card_model.dart';
import '../services/subscription_booking_service.dart';
import '../services/notification_service.dart';

class WellnessScreen extends StatefulWidget {
  final bool isDarkMode;

  const WellnessScreen({super.key, required this.isDarkMode});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> with WidgetsBindingObserver {
  int _refreshKey = 0; // Key to force stream refresh
  bool _hasInitialLoad = false;
  
  void _refreshData() {
    if (mounted) {
      setState(() {
        _refreshKey++; // Increment key to force stream rebuild
        _hasInitialLoad = true;
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh data when screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialLoad) {
        _refreshData();
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes back to foreground (user might have created a subscription in another tab)
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshData();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh only on first dependency change (when screen is first built)
    if (!_hasInitialLoad && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasInitialLoad) {
          _refreshData();
        }
      });
    }
  }
  
  /// Stream of wellness subscriptions from API as MembershipCardData
  /// Uses API endpoint 14.3: POST /api/v1/subscription/get-all-subscription
  /// Request body: {page: 1, limit: 50, categoryId: "wellness_category_id"}
  Stream<List<MembershipCardData>> getWellnessMembershipsStream() async* {
    try {
      final subscriptionService = SubscriptionService();
      final subscriptionBookingService = SubscriptionBookingService();
      final masterDataService = MasterDataService();
      
      // Fetch all categories to find wellness category and collect fitness categories
      final categories = await masterDataService.getAllCategories();
      String? wellnessCategoryId;
      List<String> fitnessCategoryIds = [];
      
      // Find wellness category by name (case-insensitive) and collect fitness categories
      for (var category in categories) {
        final categoryName = (category['cName'] ?? category['name'] ?? '').toString().toLowerCase().trim();
        final categoryId = (category['_id'] ?? category['id'] ?? '').toString();
        
        if (categoryName.isNotEmpty) {
          if (categoryName.contains('wellness') && !categoryName.contains('fitness')) {
            wellnessCategoryId = categoryId;
            print('Found wellness category: $categoryName with ID: $wellnessCategoryId');
          } else if (categoryName.contains('fitness') && !categoryName.contains('wellness')) {
            fitnessCategoryIds.add(categoryId);
            print('Found fitness category: $categoryName with ID: $categoryId');
          }
        }
      }
      
      if (wellnessCategoryId == null) {
        print('Warning: Wellness category not found. Will use client-side filtering.');
      }
      
      // API Endpoint: POST /api/v1/subscription/get-all-subscription
      // Body: {page, limit, categoryId, sessionTypeId, trainerId}
      final result = await subscriptionService.getAllSubscriptions(
        page: 1,
        limit: 100, // Increased to get more subscriptions
        categoryId: wellnessCategoryId, // Filter by wellness category if found
      );
      
      var subscriptions = result?['subscriptions'] ?? result?['data'] ?? [];
      
      print('Wellness Screen: Fetched ${subscriptions.length} subscriptions from API');
      
      // ALWAYS filter client-side as safety measure to ensure only wellness items appear
      // This handles cases where API filtering might not work correctly
      if (subscriptions.isNotEmpty) {
        subscriptions = subscriptions.where((sub) {
          final category = sub['categoryId'];
          if (category == null) {
            print('Wellness Screen: Subscription ${sub['_id']} has null categoryId');
            return false;
          }
          
          String categoryName = '';
          String categoryIdStr = '';
          
          // Handle category as Map (populated) or String/ObjectId
          if (category is Map) {
            categoryName = (category['cName'] ?? category['name'] ?? '').toString().toLowerCase().trim();
            categoryIdStr = (category['_id'] ?? category['id'] ?? '').toString();
          } else {
            categoryIdStr = category.toString();
          }
          
          // Explicitly exclude fitness categories by ID
          if (fitnessCategoryIds.isNotEmpty && fitnessCategoryIds.contains(categoryIdStr)) {
            print('Wellness Screen: Excluding subscription ${sub['name']} - fitness category ID: $categoryIdStr');
            return false;
          }
          
          // If category is just an ID, try to match with found category ID
          if (category is! Map) {
            if (wellnessCategoryId != null && categoryIdStr == wellnessCategoryId) {
              return true; // Match by ID if we found the wellness category
            }
            // If it's a fitness ID, exclude it
            if (fitnessCategoryIds.contains(categoryIdStr)) {
              return false;
            }
            // Can't determine from ID alone, skip it
            return false;
          }
          
          // Match by category name (case-insensitive)
          if (categoryName.isEmpty) {
            print('Wellness Screen: Subscription ${sub['_id']} has empty category name');
            return false;
          }
          
          // Explicitly exclude fitness
          if (categoryName.contains('fitness') || categoryName.contains('gym') || categoryName.contains('workout')) {
            print('Wellness Screen: Excluding subscription ${sub['name']} - fitness category name: $categoryName');
            return false;
          }
          
          // Include only wellness
          final isWellness = categoryName.contains('wellness') || categoryName.contains('spa') || categoryName.contains('yoga') || categoryName.contains('meditation');
          
          // Also match by ID if we found the wellness category
          if (wellnessCategoryId != null && categoryIdStr == wellnessCategoryId) {
            return true;
          }
          
          return isWellness;
        }).toList();
        
        print('Wellness Screen: After filtering, ${subscriptions.length} wellness subscriptions remain');
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
        String categoryName = 'Wellness';
        if (category is Map) {
          // Backend uses 'cName' field, but also check 'name' for compatibility
          categoryName = (category['cName'] ?? category['name'] ?? 'Wellness').toString();
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
      print('Error fetching wellness memberships: $e');
      yield [];
    }
  }

  // Session descriptions map
  static const Map<String, String> sessionDescriptions = {
    "OUTCALM": "OutCalm is a deeply relaxing meditation and sound bath session designed to soothe your mind and body. Gentle breathwork, calming soundscapes, and subtle aromatherapy help you unwind, reduce stress, and leave feeling refreshed.\n\nOutCalm is perfect for all levels and offered in 30 or 45-minute sessions.",
    "OUTROOT": "OutRoot is a grounding, nature-inspired session that blends gentle breathwork and slow movement to help you reconnect with the present. Held outdoors whenever possible, this practice uses simple grounding exercises and light stretches to restore balance and inner calm.\n\nOutRoot is suitable for all levels and offered in 30 or 45 minute sessions.",
    "OUTCREATE": "OutCreate is a playful, art-based workshop designed to spark creativity and ease the mind. Participants draw, paint, or craft as they move gently and breathe mindfully — releasing tension and self-judgment.\n\nOutCreate is perfect for all skill levels and offered in 45 minute sessions.",
    "OUTFLOW": "OutFlow is a free-form movement session that invites you to dance, stretch, and flow without judgment. Inspired by intuitive movement and set to uplifting music, it's all about releasing energy and finding joy in your body.\n\nOutFlow is suitable for everyone and offered in 30 or 45 minute sessions.",
    "OUTGLOW": "OutGlow is a gentle yoga session illuminated by candlelight, encouraging relaxation and self-care. Soft stretches, deep breaths, and calming poses help you release tension and leave with a warm inner glow.\n\nOutGlow is open to all levels and offered in 45 minute sessions.",
    "OUTSOUND": "OutSound is an immersive sound-healing session using gongs, singing bowls, and chimes to realign your energy. Let the vibrations wash over you as you sink into deep relaxation.\n\nOutSound is perfect for all levels and offered in 45 minute sessions.",
    "OUTDREAM": "OutDream is a guided visualization and relaxation practice that taps into your imagination. Gentle cues help you drift into a dream-like state, melting away stress and leaving you inspired and at ease.\n\nOutDream is suitable for all levels and offered in 30 minute sessions.",
  };

  // Session image paths map (supports both network URLs and local assets)
  static const Map<String, String> sessionImages = {
    "OUTCALM": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Meditation
    "OUTROOT": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=400&fit=crop&q=80", // Nature/grounding
    "OUTCREATE": "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800&h=400&fit=crop&q=80", // Art/creativity
    "OUTFLOW": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Movement/dance
    "OUTGLOW": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Yoga/candlelight
    "OUTSOUND": "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop&q=80", // Sound healing
    "OUTDREAM": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop&q=80", // Dream/visualization
  };

  @override
  @override
  Widget build(BuildContext context) {
    // Brand Colors - Wellness (Brown/Gold: #AD8654)
    final Color scaffoldBackground =
        widget.isDarkMode ? const Color(0xFF353535) : const Color(0xFFFCEEE5);

    final Color headlineColor =
        widget.isDarkMode ? const Color(0xFFAD8654) : const Color(0xFF353535);

    final Color subTextColor = const Color(0xFF99928D);
    final Color accentColor = const Color(0xFFAD8654); // Brown/Gold for Wellness
    
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

    /// --------------------------------------------------------
    /// WELLNESS SESSIONS (icons only top section)
    /// --------------------------------------------------------
    final sessions = [
      FitnessSession(
        label: "OUTCALM",
        icon: Icons.self_improvement,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutCalm",
          sessionDescriptions["OUTCALM"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTCALM"],
        ),
      ),
      FitnessSession(
        label: "OUTROOT",
        icon: Icons.yard,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutRoot",
          sessionDescriptions["OUTROOT"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTROOT"],
        ),
      ),
      FitnessSession(
        label: "OUTCREATE",
        icon: Icons.brush,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutCreate",
          sessionDescriptions["OUTCREATE"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTCREATE"],
        ),
      ),
      FitnessSession(
        label: "OUTFLOW",
        icon: Icons.waterfall_chart,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutFlow",
          sessionDescriptions["OUTFLOW"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTFLOW"],
        ),
      ),
      FitnessSession(
        label: "OUTGLOW",
        icon: Icons.wb_incandescent,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutGlow",
          sessionDescriptions["OUTGLOW"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTGLOW"],
        ),
      ),
      FitnessSession(
        label: "OUTSOUND",
        icon: Icons.music_note,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutSound",
          sessionDescriptions["OUTSOUND"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTSOUND"],
        ),
      ),
      FitnessSession(
        label: "OUTDREAM",
        icon: Icons.nights_stay,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutDream",
          sessionDescriptions["OUTDREAM"]!,
          widget.isDarkMode,
          imagePath: sessionImages["OUTDREAM"],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 56),

            /// TITLE
            Text(
              "Discover the best in wellness",
              style: headlineStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            Text(
              "Find peace, healing, creativity, and flow — curated for you.",
              style: bodyStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            /// ----------------------------------------
            /// ICON GRID ONLY (NO SEARCH / NO LOCATION)
            /// ----------------------------------------
            FitnessSessionsGrid(
              sessions: sessions,
              isDarkMode: widget.isDarkMode,
            ),

            const SizedBox(height: 28),

            /// TODAY'S CLASSES SECTION
            TodaysClassesList(
              isDarkMode: widget.isDarkMode,
              categoryFilter: 'wellness', // Only show wellness classes
            ),

            const SizedBox(height: 32),

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
              key: ValueKey('wellness_memberships_$_refreshKey'), // Force rebuild when refreshKey changes
              stream: getWellnessMembershipsStream(),
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

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: allMemberships
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
              searchQuery: '',
              selectedTrainer: null,
              filterFutureDate: false,
              isDarkMode: widget.isDarkMode,
              categoryFilter: 'wellness', // Only show wellness packages
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
