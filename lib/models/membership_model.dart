class MembershipCarouselData {
  final String id;
  final String imageUrl;
  final String tag;
  final bool isPurchased;
  final String classes;
  final String type;
  final String title;
  final String price;
  final List<String> features;
  final String mentor;
  final String date;    // <-- NEW FIELD

  MembershipCarouselData({
    required this.id,
    required this.imageUrl,
    required this.tag,
    required this.isPurchased,
    required this.classes,
    required this.type,
    required this.title,
    required this.price,
    required this.features,
    required this.mentor,
    required this.date,       // <-- NEW
  });

  factory MembershipCarouselData.fromFirestore(Map<String, dynamic> json, String id) {
    return MembershipCarouselData(
      id: id,
      imageUrl: json["imageUrl"] ?? "",
      tag: json["tag"] ?? "",
      isPurchased: json["isPurchased"] ?? false,
      classes: json["classes"] ?? "",
      type: json["type"] ?? "",
      title: json["title"] ?? "",
      price: json["price"] ?? "",
      features: List<String>.from(json["features"] ?? []),
      mentor: json["mentor"] ?? "",
      date: json["date"] ?? "",   // <-- NEW
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "imageUrl": imageUrl,
      "tag": tag,
      "isPurchased": isPurchased,
      "classes": classes,
      "type": type,
      "title": title,
      "price": price,
      "features": features,
      "mentor": mentor,
      "date": date,  // <-- NEW
    };
  }
}
