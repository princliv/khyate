import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WellnessCardManager extends StatefulWidget {
  @override
  State<WellnessCardManager> createState() => _WellnessCardManagerState();
}

class _WellnessCardManagerState extends State<WellnessCardManager> {
  final _imageUrl = TextEditingController();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _description = TextEditingController();
  final _category = TextEditingController();
  final _duration = TextEditingController();
  final _mentor = TextEditingController();
  final _price = TextEditingController();

  void _addWellnessCard() {
    FirebaseFirestore.instance.collection("wellnesscards").add({
      "imageUrl": _imageUrl.text,
      "title": _title.text,
      "subtitle": _subtitle.text,
      "description": _description.text,
      "category": _category.text,
      "duration": _duration.text,
      "mentor": _mentor.text,
      "price": _price.text,
    });

    _imageUrl.clear();
    _title.clear();
    _subtitle.clear();
    _description.clear();
    _category.clear();
    _duration.clear();
    _mentor.clear();
    _price.clear();
  }

  void _delete(String id) {
    FirebaseFirestore.instance.collection("wellnesscards").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputForm(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("wellnesscards")
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return Center(child: CircularProgressIndicator());

              final docs = snap.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];

                  return ListTile(
                    title: Text(d['title']),
                    subtitle: Text("${d['category']} • ${d['duration']}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(d.id),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _inputForm() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _field(_imageUrl, "Image URL"),
          _field(_title, "Title"),
          _field(_subtitle, "Subtitle"),
          _field(_description, "Description"),
          _field(_category, "Category"),
          _field(_duration, "Duration"),
          _field(_mentor, "Mentor"),
          _field(_price, "Price"),

          ElevatedButton(
            onPressed: _addWellnessCard,
            child: Text("Add Wellness Card"),
          )
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
