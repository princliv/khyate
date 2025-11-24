import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khyate_b2b/screens/purchase_list_screen.dart';

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
  final _price = TextEditingController();

  String? selectedTrainer;  
  List<DocumentSnapshot> trainers = [];

  @override
  void initState() {
    super.initState();

    // FETCH TRAINERS FROM FIRESTORE
    FirebaseFirestore.instance.collection("trainers").snapshots().listen((snap) {
      setState(() {
        trainers = snap.docs;
      });
    });
  }

  void _addWellnessCard() {
    FirebaseFirestore.instance.collection("wellnesscards").add({
      "imageUrl": _imageUrl.text.trim(),
      "title": _title.text.trim(),
      "subtitle": _subtitle.text.trim(),
      "description": _description.text.trim(),
      "category": _category.text.trim(),
      "duration": _duration.text.trim(),
      "mentor": selectedTrainer ?? "No Trainer Assigned",
      "price": _price.text.trim(),
    });

    _imageUrl.clear();
    _title.clear();
    _subtitle.clear();
    _description.clear();
    _category.clear();
    _duration.clear();
    _price.clear();
    selectedTrainer = null;

    setState(() {});
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
  subtitle: Text("${d['category']} • ${d['duration']} • 👤 ${d['mentor']}"),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 🔵 VIEW PURCHASED USERS BUTTON
      IconButton(
        icon: Icon(Icons.people, color: Colors.blue),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseListScreen(
                cardId: d.id,
                cardTitle: d["title"],
              ),
            ),
          );
        },
      ),

      // 🔴 DELETE BUTTON
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _delete(d.id),
      ),
    ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(_imageUrl, "Image URL"),
          _field(_title, "Title"),
          _field(_subtitle, "Subtitle"),
          _field(_description, "Description"),
          _field(_category, "Category"),
          _field(_duration, "Duration"),
          _field(_price, "Price"),

          SizedBox(height: 10),

          Text("Select Trainer", style: TextStyle(fontWeight: FontWeight.bold)),

          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              hint: Text("Choose Trainer"),
              value: selectedTrainer,
              isExpanded: true,
              underline: SizedBox(),
              items: trainers.map((t) {
                return DropdownMenuItem<String>(
                  value: t["name"],
                  child: Text(t["name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTrainer = value;
                });
              },
            ),
          ),

          SizedBox(height: 10),

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
