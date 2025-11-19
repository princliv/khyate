import 'package:flutter/material.dart';

class MembershipCarouselData {
  final String imageUrl;
  final String tag;
  final bool isPurchased;
  final String classes;
  final String type;
  final String title;
  final String price;
  final List<String> features;
  final VoidCallback? onButtonPressed;

  MembershipCarouselData({
    required this.imageUrl,
    required this.tag,
    required this.isPurchased,
    required this.classes,
    required this.type,
    required this.title,
    required this.price,
    required this.features,
    this.onButtonPressed,
  });
}

class MembershipCarousel extends StatelessWidget {
  final List<MembershipCarouselData>? cards; // Allow optional prop for future backend

  const MembershipCarousel({super.key, this.cards});

  List<MembershipCarouselData> get _defaultCards => [
    MembershipCarouselData(
      imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
      tag: "daily",
      isPurchased: false,
      classes: "101 Classes",
      type: "Wakeup Soul1",
      title: "AED 201",
      price: "/package",
      features: [
        "Test Features 11",
        "Test Features 21",
        "Test Features 311"
      ],
      onButtonPressed: () {},
    ),
    MembershipCarouselData(
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      tag: "monthly",
      isPurchased: false,
      classes: "45 Classes",
      type: "Summer Package",
      title: "AED 129",
      price: "/package",
      features: ["package of 45 classes", "feature 2"],
      onButtonPressed: () {},
    ),
    MembershipCarouselData(
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      tag: "monthly",
      isPurchased: true,
      classes: "12 Classes",
      type: "Winter Package",
      title: "AED 123",
      price: "/package",
      features: [
        "package of 10 classes",
        "one month package",
        "cheap price"
      ],
      onButtonPressed: () {},
    ),
    MembershipCarouselData(
      imageUrl: 'https://images.unsplash.com/photo-1519864600361-7efb74e05aa0?auto=format&fit=crop&w=800&q=80',
      tag: "monthly",
      isPurchased: false,
      classes: "31 Classes",
      type: "December Program",
      title: "AED 150",
      price: "/package",
      features: ["15 core classes", "advanced track", "feature X"],
      onButtonPressed: () {},
    ),
    // Add 4 more cards as needed...
  ];

  @override
  Widget build(BuildContext context) {
    final items = cards ?? _defaultCards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(
          "Find Your New Latest Packages",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 410,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final card = items[index];
              return Container(
                width: 300,
                margin: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(
                            card.imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (card.isPurchased)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Color(0xFF4ABC76),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text("Purchased", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  card.tag,
                                  style: TextStyle(
                                    color: Color(0xFF33313F),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCEF9EF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  card.classes,
                                  style: TextStyle(
                                    color: Color(0xFF16AE8E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            card.type,
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(card.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(card.price, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            ],
                          ),
                          SizedBox(height: 12),
                          for (final f in card.features)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Icon(Icons.check, color: Color(0xFF16AE8E), size: 18),
                                  SizedBox(width: 5),
                                  Text(f, style: TextStyle(fontSize: 15, color: Colors.black87)),
                                ],
                              ),
                            ),
                          if (card.isPurchased)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFD8D8D8),
                                    foregroundColor: Color(0xFF606060),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text("Already Purchased", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: card.onButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2EC9A6),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text("Buy Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
