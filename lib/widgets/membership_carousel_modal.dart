import 'package:Outbox/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:Outbox/models/membership_model.dart';

class MembershipCarouselModal extends StatelessWidget {
  final MembershipCarouselData data;

  const MembershipCarouselModal({
    super.key,
    required this.data,
  });

  static void show(BuildContext context, MembershipCarouselData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MembershipCarouselModal(data: data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2332),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF1A2332)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // Image
              if (data.imageUrl.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Image.asset(
                            'assets/default_thumbnail.webp',
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: data.imageUrl.isNotEmpty ? 0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE7F4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              data.tag,
                              style: const TextStyle(
                                color: Color(0xFFDF50B7),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "AED ${data.price}",
                            style: const TextStyle(
                              color: Color(0xFF1A2332),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Features Section
                      const Text(
                        "Features",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2332),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Features List
                      ...data.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check,
                                color: Color(0xFF16AE8E),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Details Section
                      const Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2332),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Trainer
                      if (data.mentor.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFFDF50B7), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Trainer: ${data.mentor}",
                                style: const TextStyle(color: Colors.black54, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      // Date
                      if (data.date.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFFDF50B7), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Date: ${data.date}",
                                style: const TextStyle(color: Colors.black54, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      // Location
                      if (data.location.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFDF50B7), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Location: ${data.location}",
                                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>?>(
  future: ReviewService.getUserReview(data.id),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return SizedBox(); // loading or no review
    }

    final userReview = snapshot.data;
    if (userReview == null) {
      return SizedBox(); // user never reviewed
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Your Review",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2332),
          ),
        ),

        SizedBox(height: 8),

        // Rating
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 6),
            Text(
              userReview['rating'].toString(),
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),

        SizedBox(height: 6),

        // Comment
        Text(
          userReview['comment'] ?? "",
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  },
),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Close button at bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6767),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

