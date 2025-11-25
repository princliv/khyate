class WellnessCard {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String duration;
  final String mentor;
  final String price;
  final String date;       // <-- NEW
  final bool isPurchased;

  WellnessCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.duration,
    required this.mentor,
    required this.price,
    required this.date,     // <-- NEW
    required this.isPurchased,
  });

  factory WellnessCard.fromMap(String id, Map<String, dynamic> data) {
    return WellnessCard(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? '',
      mentor: data['mentor'] ?? '',
      price: data['price'] ?? '',
      date: data['date'] ?? '',        // <-- NEW
      isPurchased: data['isPurchased'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "imageUrl": imageUrl,
      "title": title,
      "subtitle": subtitle,
      "description": description,
      "category": category,
      "duration": duration,
      "mentor": mentor,
      "price": price,
      "date": date,                    // <-- NEW
      "isPurchased": isPurchased,
    };
  }
}
