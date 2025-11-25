import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchaseListScreen extends StatefulWidget {
  final String cardId;
  final String cardTitle;

  const PurchaseListScreen({
    super.key,
    required this.cardId,
    required this.cardTitle,
  });

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  List<Map<String, dynamic>> purchasedUsers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPurchasedUsers();
  }

  /// Fetch all users who purchased this membership/card
Future<void> fetchPurchasedUsers() async {
  final usersSnap = await FirebaseFirestore.instance.collection("users").get();

  List<Map<String, dynamic>> temp = [];

  for (var userDoc in usersSnap.docs) {
    final userId = userDoc.id;

    final purchaseDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("purchases")
        .doc(widget.cardId)   // ✔ check using docId
        .get();

    if (purchaseDoc.exists) {
      temp.add({
        "name": userDoc.data()?["name"] ?? "No Name",
        "email": userDoc.data()?["email"] ?? "No Email",
        "userId": userId,
        "purchaseDate": 
    (purchaseDoc.data()?["purchasedAt"] is Timestamp)
        ? (purchaseDoc.data()?["purchasedAt"] as Timestamp).toDate()
        : "Unknown Date",

      });
    }
  }

  setState(() {
    purchasedUsers = temp;
    loading = false;
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Members of ${widget.cardTitle}"),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : purchasedUsers.isEmpty
              ? Center(child: Text("No members have purchased this yet."))
              : ListView.builder(
                  itemCount: purchasedUsers.length,
                  itemBuilder: (context, index) {
                    final user = purchasedUsers[index];

                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(user["name"]),
                      subtitle: Text(user["email"]),
                      trailing: Text(
                        user["purchaseDate"].toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
    );
  }
}
