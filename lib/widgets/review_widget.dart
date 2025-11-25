import 'package:flutter/material.dart';
import '../services/review_service.dart';

class ReviewWidget extends StatefulWidget {
  final String cardId;
  const ReviewWidget({super.key, required this.cardId});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  double rating = 0;
  final commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⭐ Average Rating
        StreamBuilder<double>(
          stream: ReviewService.avgRating(widget.cardId),
          builder: (context, snap) {
            if (!snap.hasData) return Text("⭐ Loading rating...");

            return Text(
              "⭐ Average Rating: ${snap.data!.toStringAsFixed(1)} / 5",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            );
          },
        ),

        const SizedBox(height: 10),

        // ⭐ Rating Picker
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => rating = index + 1.0),
            );
          }),
        ),

        // ✍ Comment Box
        TextField(
          controller: commentCtrl,
          decoration: InputDecoration(
            labelText: "Write a comment...",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 10),

        // SUBMIT BUTTON
        ElevatedButton(
          onPressed: () {
            if (rating == 0) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Select rating first")));
              return;
            }

            ReviewService.submitReview(
              cardId: widget.cardId,
              rating: rating,
              comment: commentCtrl.text,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Review submitted!")),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: Text("Submit Review"),
        ),
      ],
    );
  }
}
