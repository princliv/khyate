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
  final bool isPurchased;
  final String date;   // <-- NEW FIELD
  final String location; // <-- NEW FIELD


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
  required this.date,
  required this.location,   // <-- NEW
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
    date: data["date"] ?? "",
    location: data["location"] ?? "",  // <-- NEW
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
    "date": date,
    "location": location,   // <-- NEW
  };
}

}
