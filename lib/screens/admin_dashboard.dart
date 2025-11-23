import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MembershipCarouselManager(),
          FitnessMembershipCardManager(),
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

  void _addMembership() {
    FirebaseFirestore.instance.collection("memberships").add({
      "imageUrl": _imageUrl.text,
      "tag": _tag.text,
      "classes": _classes.text,
      "type": _type.text,
      "title": _title.text,
      "price": _price.text,
      "features": _features.text.split(","),
      "isPurchased": false,
    });

    _imageUrl.clear();
    _tag.clear();
    _classes.clear();
    _type.clear();
    _title.clear();
    _price.clear();
    _features.clear();
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
            stream:
                FirebaseFirestore.instance.collection("memberships").snapshots(),
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
                    subtitle: Text(d['type']),
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
        children: [
          _field(_imageUrl, "Image URL"),
          _field(_tag, "Tag"),
          _field(_classes, "Classes"),
          _field(_type, "Type"),
          _field(_title, "Title"),
          _field(_price, "Price"),
          _field(_features, "Features (comma separated)"),
          ElevatedButton(
            onPressed: _addMembership,
            child: Text("Add Membership"),
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
  final _description = TextEditingController();
  final _time = TextEditingController();
  final _mentor = TextEditingController();
  final _reviews = TextEditingController();

  void _addCard() {
    FirebaseFirestore.instance.collection("membershipcards").add({
      "imageUrl": _imageUrl.text,
      "category": _category.text,
      "price": _price.text,
      "title": _title.text,
      "description": _description.text,
      "time": _time.text,
      "mentor": _mentor.text,
      "reviews": _reviews.text,
    });

    _imageUrl.clear();
    _category.clear();
    _price.clear();
    _title.clear();
    _description.clear();
    _time.clear();
    _mentor.clear();
    _reviews.clear();
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
              if (!snap.hasData) return Center(child: CircularProgressIndicator());

              final docs = snap.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return ListTile(
                    title: Text(d['title']),
                    subtitle: Text(d['category']),
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
        children: [
          _field(_imageUrl, "Image URL"),
          _field(_category, "Category"),
          _field(_price, "Price"),
          _field(_title, "Title"),
          _field(_description, "Description"),
          _field(_time, "Time"),
          _field(_mentor, "Mentor"),
          _field(_reviews, "Reviews"),
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
