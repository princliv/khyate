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
    );
  }
}
