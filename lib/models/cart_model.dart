class CartItem {
  final String id; // document ID
  final String title;
  final String imageUrl;
  final int price;
  final String type; // wellness / membership / membership_card

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.type,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String,
      price: map['price'] is int ? map['price'] as int : int.tryParse(map['price'].toString()) ?? 0,
      type: map['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'type': type,
    };
  }
}
