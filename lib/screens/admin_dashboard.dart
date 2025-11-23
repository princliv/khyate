import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khyate_b2b/screens/admin/trainer_manager.dart';
import 'package:khyate_b2b/screens/admin/wellness_card_manager.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Memberships (Carousel)"),
            Tab(text: "Fitness Cards"),
            Tab(text: "Wellness Cards"),
            Tab(text: "Trainers"),

          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MembershipCarouselManager(),
          FitnessMembershipCardManager(),
          WellnessCardManager(),
          TrainerManager(), 

        ],
      ),
    );
  }
}
class MembershipCarouselManager extends StatefulWidget {
  @override
  State<MembershipCarouselManager> createState() =>
      _MembershipCarouselManagerState();
}

class _MembershipCarouselManagerState
    extends State<MembershipCarouselManager> {
  final _imageUrl = TextEditingController();
  final _tag = TextEditingController();
  final _classes = TextEditingController();
  final _type = TextEditingController();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _features = TextEditingController();

  // TRAINER DROPDOWN VARIABLES
  String? selectedTrainer;
  List<DocumentSnapshot> trainers = [];

  @override
  void initState() {
    super.initState();

    // Fetch trainer list from Firestore
    FirebaseFirestore.instance.collection("trainers").snapshots().listen((snap) {
      setState(() {
        trainers = snap.docs;
      });
    });
  }

  void _addMembership() {
    FirebaseFirestore.instance.collection("memberships").add({
      "imageUrl": _imageUrl.text,
      "tag": _tag.text,
      "classes": _classes.text,
      "type": _type.text,
      "title": _title.text,
      "price": _price.text,
      "features": _features.text.split(","),
      "mentor": selectedTrainer ?? "No Trainer Assigned",
      "isPurchased": false,
    });

    _imageUrl.clear();
    _tag.clear();
    _classes.clear();
    _type.clear();
    _title.clear();
    _price.clear();
    _features.clear();
    selectedTrainer = null;

    setState(() {});
  }

  void _delete(String id) {
    FirebaseFirestore.instance.collection("memberships").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputForm(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("memberships")
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final docs = snap.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return ListTile(
                    title: Text(d['title']),
                    subtitle: Text("Type: ${d['type']}  | Trainer: ${d['mentor']}"),
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
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(_imageUrl, "Image URL"),
          _field(_tag, "Tag"),
          _field(_classes, "Classes"),
          _field(_type, "Type"),
          _field(_title, "Title"),
          _field(_price, "Price"),
          _field(_features, "Features (comma separated)"),

          SizedBox(height: 10),

          // TRAINER DROPDOWN
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
            onPressed: _addMembership,
            child: Text("Add Membership Carousel Card"),
          )
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
class FitnessMembershipCardManager extends StatefulWidget {
  @override
  State<FitnessMembershipCardManager> createState() =>
      _FitnessMembershipCardManagerState();
}

class _FitnessMembershipCardManagerState
    extends State<FitnessMembershipCardManager> {
  final _imageUrl = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _description = TextEditingController();
  final _duration = TextEditingController();

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

  void _addCard() {
    FirebaseFirestore.instance.collection("membershipcards").add({
      "imageUrl": _imageUrl.text.trim(),
      "category": _category.text.trim(),
      "price": _price.text.trim(),
      "title": _title.text.trim(),
      "subtitle": _subtitle.text.trim(),
      "description": _description.text.trim(),
      "duration": _duration.text.trim(),
      "mentor": selectedTrainer ?? "No Trainer Assigned",
    });

    // CLEAR FIELDS
    _imageUrl.clear();
    _category.clear();
    _price.clear();
    _title.clear();
    _subtitle.clear();
    _description.clear();
    _duration.clear();
    selectedTrainer = null;

    setState(() {});
  }

  void _delete(String id) {
    FirebaseFirestore.instance.collection("membershipcards").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputForm(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("membershipcards")
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final docs = snap.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return ListTile(
                    title: Text(d['title']),
                    subtitle: Text("Category: ${d['category']}"),
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
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(_imageUrl, "Image URL"),
          _field(_category, "Category"),
          _field(_price, "Price"),
          _field(_title, "Title"),
          _field(_subtitle, "Subtitle"),
          _field(_description, "Description"),
          _field(_duration, "Duration"),

          SizedBox(height: 10),

          // TRAINER DROPDOWN
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
            onPressed: _addCard,
            child: Text("Add Fitness Card"),
          )
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
