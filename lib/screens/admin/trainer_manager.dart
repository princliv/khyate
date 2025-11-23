import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerManager extends StatefulWidget {
  @override
  State<TrainerManager> createState() => _TrainerManagerState();
}

class _TrainerManagerState extends State<TrainerManager> {
  final _name = TextEditingController();
  final _expertise = TextEditingController();
  final _imageUrl = TextEditingController();

  void _addTrainer() {
    FirebaseFirestore.instance.collection("trainers").add({
      "name": _name.text,
      "expertise": _expertise.text,
      "imageUrl": _imageUrl.text,
    });

    _name.clear();
    _expertise.clear();
    _imageUrl.clear();
  }

  void _delete(String id) {
    FirebaseFirestore.instance.collection("trainers").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputForm(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("trainers").snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return Center(child: CircularProgressIndicator());

              final docs = snap.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(d['imageUrl']),
                    ),
                    title: Text(d['name']),
                    subtitle: Text(d['expertise']),
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
          _field(_name, "Trainer Name"),
          _field(_expertise, "Expertise"),
          _field(_imageUrl, "Image URL"),
          ElevatedButton(
            onPressed: _addTrainer,
            child: Text("Add Trainer"),
          ),
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
