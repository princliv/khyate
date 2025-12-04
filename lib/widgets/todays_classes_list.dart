import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Today’s Classes
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
  });

  factory TodayClassData.fromFirestore(Map<String, dynamic> data, String id) {
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

/// Fetch today’s classes from both collections
Future<List<TodayClassData>> fetchTodaysClasses() async {
final today = DateTime.now();
final todayStr = "${today.day}-${today.month}-${today.year}"; // matches Firestore


  final firestore = FirebaseFirestore.instance;

  final List<TodayClassData> results = [];

  // Fetch memberships
  final memberships = await firestore
      .collection('memberships')
      .where("date", isEqualTo: todayStr)
      .get();

  for (var doc in memberships.docs) {
    results.add(TodayClassData.fromFirestore(doc.data(), doc.id));
  }

  // Fetch membershipcards
  final membershipcards = await firestore
      .collection('membershipcards')
      .where("date", isEqualTo: todayStr)
      .get();

  for (var doc in membershipcards.docs) {
    results.add(TodayClassData.fromFirestore(doc.data(), doc.id));
  }

  return results;
}

/// Widget for displaying Today’s Classes horizontally
class TodaysClassesList extends StatelessWidget {
  const TodaysClassesList({super.key});

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
            const Text(
              "Today's Classes",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 360,
              child: Stack(
                children: [
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: classes.length,
                    padding: const EdgeInsets.only(right: 40), // space for arrow
                    itemBuilder: (ctx, i) {
                      final c = classes[i];
                      return _buildTodayCard(c);
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

Widget _buildTodayCard(TodayClassData c) {
  return Container(
    width: 260,
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView( // allows scrolling if text is long
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  c.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 6),
            Text(c.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (c.description != null && c.description!.isNotEmpty) ...[
              Text(
                c.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],
            if (c.features != null && c.features!.isNotEmpty) ...[
              const Text(
                "Features:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...c.features!.map((f) => Row(
                    children: [
                      const Icon(Icons.check, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.pinkAccent),
                const SizedBox(width: 6),
                Text(c.mentor),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(c.time),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    c.location,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (c.date.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                c.date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

}
