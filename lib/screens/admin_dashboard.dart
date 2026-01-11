import 'package:Outbox/screens/admin/trainer_manager.dart';
import 'package:Outbox/screens/admin/wellness_card_manager.dart';
import 'package:Outbox/screens/admin/subservice_manager.dart';
import 'package:Outbox/screens/admin/promo_code_manager.dart';
import 'package:Outbox/screens/admin/article_manager.dart';
import 'package:Outbox/screens/admin/planner_dashboard_screen.dart';
import 'package:Outbox/screens/admin/available_groomers_screen.dart';
import 'package:Outbox/screens/admin/subscription_manager.dart';
import 'package:Outbox/screens/admin/package_manager.dart';
import 'package:Outbox/screens/purchase_list_screen.dart';
import 'package:flutter/material.dart';
// import 'package:khyate_b2b/screens/admin/trainer_manager.dart';
// import 'package:khyate_b2b/screens/admin/wellness_card_manager.dart';
// import 'package:khyate_b2b/screens/purchase_list_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


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
    _tabController = TabController(length: 11, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard, size: 28),
            SizedBox(width: 12),
            Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.card_membership, size: 20), text: "Memberships"),
            Tab(icon: Icon(Icons.fitness_center, size: 20), text: "Fitness Cards"),
            Tab(icon: Icon(Icons.spa, size: 20), text: "Wellness Cards"),
            Tab(icon: Icon(Icons.person, size: 20), text: "Trainers"),
            Tab(icon: Icon(Icons.build, size: 20), text: "Sub Services"),
            Tab(icon: Icon(Icons.local_offer, size: 20), text: "Promo Codes"),
            Tab(icon: Icon(Icons.article, size: 20), text: "Articles"),
            Tab(icon: Icon(Icons.subscriptions, size: 20), text: "Subscriptions"),
            Tab(icon: Icon(Icons.inventory, size: 20), text: "Packages"),
            Tab(icon: Icon(Icons.calendar_today, size: 20), text: "Planner"),
            Tab(icon: Icon(Icons.people, size: 20), text: "Groomers"),
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
          SubServiceManager(),
          PromoCodeManager(),
          ArticleManager(),
          SubscriptionManager(),
          PackageManager(),
          PlannerDashboardScreen(),
          AvailableGroomersScreen(),
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
  final _location = TextEditingController();

  String? selectedTrainer;
  List<Map<String, dynamic>> trainers = [];
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    // TODO: Implement with your API
    // YourApiService.getTrainersStream().listen((trainers) {
    //   setState(() {
    //     this.trainers = trainers;
    //   });
    // });
  }

  void _addMembership() {
    // TODO: Implement with your API
    // await YourApiService.createMembership({
    //   "imageUrl": _imageUrl.text,
    //   "tag": _tag.text,
    //   "classes": _classes.text,
    //   "type": _type.text,
    //   "title": _title.text,
    //   "price": _price.text,
    //   "features": _features.text.split(","),
    //   "mentor": selectedTrainer ?? "No Trainer Assigned",
    //   "isPurchased": false,
    //   "date": selectedDate ?? "",
    //   "location": _location.text.trim(),
    // });

    _imageUrl.clear();
    _tag.clear();
    _classes.clear();
    _type.clear();
    _title.clear();
    _price.clear();
    _features.clear();
    selectedTrainer = null;
  }

  void _delete(String id) {
    // TODO: Implement with your API
    // await YourApiService.deleteMembership(id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputForm(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Stream.value([]), // TODO: Replace with YourApiService.getMembershipsStream()
              builder: (context, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final docs = snap.data!;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    return ListTile(
                      title: Text(d['title'] ?? ''),
                      subtitle: Text("Type: ${d['type'] ?? ''} | Trainer: ${d['mentor'] ?? ''}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.people, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PurchaseListScreen(
                                    cardId: d['id'] ?? '',
                                    cardTitle: d["title"] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _delete(d['id'] ?? ''),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(_imageUrl, "Image URL"),
        _field(_tag, "Tag"),
        _field(_classes, "Classes"),
        _field(_type, "Type"),
        _field(_title, "Title"),
        _field(_price, "Price"),
        _field(_features, "Features (comma separated)"),
        _field(_location, "Location (Optional)"),
        SizedBox(height: 10),
        Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                selectedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(selectedDate ?? "Choose Date", style: TextStyle(fontSize: 16)),
          ),
        ),
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
                value: t["name"] ?? '',
                child: Text(t["name"] ?? ''),
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
        ),
      ],
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
  final _location = TextEditingController();

  String? selectedTrainer;
  List<Map<String, dynamic>> trainers = [];
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    // TODO: Implement with your API
    // YourApiService.getTrainersStream().listen((trainers) {
    //   setState(() {
    //     this.trainers = trainers;
    //   });
    // });
  }

  void _addCard() {
    // TODO: Implement with your API
    // await YourApiService.createMembershipCard({
    //   "imageUrl": _imageUrl.text.trim(),
    //   "category": _category.text.trim(),
    //   "price": _price.text.trim(),
    //   "title": _title.text.trim(),
    //   "subtitle": _subtitle.text.trim(),
    //   "description": _description.text.trim(),
    //   "duration": _duration.text.trim(),
    //   "mentor": selectedTrainer ?? "No Trainer Assigned",
    //   "date": selectedDate ?? "",
    //   "location": _location.text.trim(),
    // });

    _imageUrl.clear();
    _category.clear();
    _price.clear();
    _title.clear();
    _subtitle.clear();
    _description.clear();
    _duration.clear();
    selectedTrainer = null;
  }

  void _delete(String id) {
    // TODO: Implement with your API
    // await YourApiService.deleteMembershipCard(id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputForm(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Stream.value([]), // TODO: Replace with YourApiService.getMembershipCardsStream()
              builder: (context, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final docs = snap.data!;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    return ListTile(
                      title: Text(d['title'] ?? ''),
                      subtitle: Text("Category: ${d['category'] ?? ''} | Trainer: ${d['mentor'] ?? ''}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.people, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PurchaseListScreen(
                                    cardId: d['id'] ?? '',
                                    cardTitle: d["title"] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _delete(d['id'] ?? ''),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(_imageUrl, "Image URL"),
        _field(_category, "Category"),
        _field(_price, "Price"),
        _field(_title, "Title"),
        _field(_subtitle, "Subtitle"),
        _field(_description, "Description"),
        _field(_duration, "Duration"),
        _field(_location, "Location (Optional)"),
        SizedBox(height: 10),
        Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                selectedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(selectedDate ?? "Choose Date", style: TextStyle(fontSize: 16)),
          ),
        ),
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
                value: t["name"] ?? '',
                child: Text(t["name"] ?? ''),
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
        ),
      ],
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
