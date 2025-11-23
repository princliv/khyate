class CartItem {
  final String id;          // document ID
  final String title;
  final String imageUrl;
  final int price;
  final String type;        // wellness / membership / membership_card

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.type,
  });
}
