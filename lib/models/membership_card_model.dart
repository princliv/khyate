class MembershipCardData {
  final String id;
  final String imageUrl;
  final String category;
  final String price;
  final String title;
  final String description;
  final String time;
  final String mentor;
  final String reviews;
  final bool isPurchased;  // <--- NEW FIELD

  MembershipCardData({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.title,
    required this.description,
    required this.time,
    required this.mentor,
    required this.reviews,
    required this.isPurchased,
  });

  factory MembershipCardData.fromFirestore(Map<String, dynamic> data, String id) {
    return MembershipCardData(
      id: id,
      imageUrl: data["imageUrl"] ?? "",
      category: data["category"] ?? "",
      price: data["price"] ?? "",
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      time: data["time"] ?? "",
      mentor: data["mentor"] ?? "",
      reviews: data["reviews"] ?? "",
      isPurchased: data["isPurchased"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "imageUrl": imageUrl,
      "category": category,
      "price": price,
      "title": title,
      "description": description,
      "time": time,
      "mentor": mentor,
      "reviews": reviews,
      "isPurchased": isPurchased,
    };
  }
}
