import 'package:flutter/material.dart';
import 'package:Outbox/widgets/todays_class_modal.dart';
import '../services/subscription_service.dart';

/// Model for Today's Classes
class TodayClassData {
  final String id;
  final String title;
  final String mentor;
  final String time;
  final String date;
  final String location;
  final String imageUrl;
  final String? description;       // optional
  final List<String>? features;    // optional
  final String? price;             // optional

  TodayClassData({
    required this.id,
    required this.title,
    required this.mentor,
    required this.time,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.description,
    this.features,
    this.price,
  });

  factory TodayClassData.fromJson(Map<String, dynamic> data, String id) {
    return TodayClassData(
      id: id,
      title: data["title"] ?? "",
      mentor: data["mentor"] ?? "",
      time: data["time"] ?? "",
      date: data["date"] ?? "",
      location: data["location"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      description: data["description"],          // may be null
      features: data["features"] != null
          ? List<String>.from(data["features"])
          : null,
      price: data["price"],                      // may be null
    );
  }
}


/// Convert DD-MM-YYYY string to DateTime
DateTime? parseDDMMYYYY(String dateString) {
  try {
    final parts = dateString.split("-");
    if (parts.length != 3) return null;

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    return DateTime(year, month, day);
  } catch (e) {
    return null;
  }
}

/// Fetch today's classes from your API
Future<List<TodayClassData>> fetchTodaysClasses() async {
  try {
    final subscriptionService = SubscriptionService();
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Fetch subscriptions for today
    final result = await subscriptionService.getSubscriptionsByDate(date: todayStr);
    final subscriptions = result?['subscriptions'] ?? result?['data'] ?? [];
    
    // Convert subscriptions to TodayClassData
    return subscriptions.map<TodayClassData>((sub) {
      final id = sub['_id']?.toString() ?? sub['id']?.toString() ?? '';
      final trainer = sub['trainer'];
      final trainerName = trainer is Map 
          ? '${trainer['first_name'] ?? ''} ${trainer['last_name'] ?? ''}'.trim()
          : trainer?.toString() ?? 'Unknown Trainer';
      
      final address = sub['Address'] is Map ? sub['Address'] : {};
      final location = address['location']?.toString() ?? 
                      address['addressLine1']?.toString() ?? 
                      'Location TBD';
      
      return TodayClassData(
        id: id,
        title: sub['name'] ?? 'Class',
        mentor: trainerName,
        time: '${sub['startTime'] ?? ''} - ${sub['endTime'] ?? ''}',
        date: todayStr,
        location: location,
        imageUrl: sub['media'] ?? sub['imageUrl'] ?? '',
        description: sub['description'],
        price: sub['price']?.toString(),
      );
    }).toList();
  } catch (e) {
    print('Error fetching today\'s classes: $e');
    return [];
  }
}

/// Widget for displaying Today's Classes horizontally
class TodaysClassesList extends StatelessWidget {
  final bool isDarkMode;
  
  const TodaysClassesList({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TodayClassData>>(
      future: fetchTodaysClasses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data!;

        if (classes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text("No classes today"),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Classes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: classes.length,
                    padding: const EdgeInsets.only(right: 40), // space for arrow
                    itemBuilder: (ctx, i) {
                      final c = classes[i];
                      return _buildTodayCard(ctx, c, isDarkMode);
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

Widget _buildTodayCard(BuildContext context, TodayClassData c, bool isDarkMode) {
  return InkWell(
    onTap: () {
      TodaysClassModal.show(context, c, isDarkMode: isDarkMode);
    },
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // IMAGE - Always show, with default fallback
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: c.imageUrl.isNotEmpty
                ? Image.network(
                    c.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/default_thumbnail.webp',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/default_thumbnail.webp',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          
          // CONTENT SECTION
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TITLE
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // DETAILS SECTION - Well organized
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      // Trainer
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18, color: Color(0xFFDF50B7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.mentor,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Location
                      if (c.location.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Color(0xFFDF50B7)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Date - Right aligned
                      if (c.date.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            c.date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
