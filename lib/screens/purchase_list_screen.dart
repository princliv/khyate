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
  // TODO: Implement with your API
  // Example:
  // final users = await YourApiService.getUsersWhoPurchased(widget.cardId);
  // setState(() {
  //   purchasedUsers = users;
  //   loading = false;
  // });
  
  setState(() {
    purchasedUsers = [];
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
