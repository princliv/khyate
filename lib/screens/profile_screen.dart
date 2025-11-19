import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;

  const ProfileScreen({super.key, required this.isDarkMode});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final birthday = TextEditingController();
  final gender = TextEditingController();
  final emiratesId = TextEditingController();
  final address = TextEditingController();
  final country = TextEditingController();
  final phone = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        firstName.text = data['firstName'] ?? '';
        lastName.text = data['lastName'] ?? '';
        email.text = data['email'] ?? '';
        birthday.text = data['birthday'] ?? '';
        gender.text = data['gender'] ?? '';
        emiratesId.text = data['emiratesId'] ?? '';
        address.text = data['address'] ?? '';
        country.text = data['country'] ?? '';
        phone.text = data['phone'] ?? '';
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> updateSection(Map<String, dynamic> updates) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: Text("Profile updated"),
            backgroundColor: Color(0xfff8e6da),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
    }
  }

  void showEditDialog({
    required String title,
    required List<Widget> fields,
    required VoidCallback onSave,
  }) {
    final isDark = widget.isDarkMode;
    
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: isDark ? Color(0xFF1E293B) : Color(0xfffdf4ee),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ...fields,
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xfff8e6da),
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Changes"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget infoRow(String label, String value, Color textColor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Color(0xFF374151) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xfff8e6da).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xfff8e6da).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Color(0xfff8e6da)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "Not set",
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isNotEmpty ? textColor : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required String title,
    required List<Widget> children,
    bool showEdit = false,
    VoidCallback? onEdit,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xfffdf4ee),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xfff8e6da).withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (showEdit)
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xfff8e6da), Color(0xfff5d9c8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xfff8e6da).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: Colors.black87),
                              const SizedBox(width: 6),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: widget.isDarkMode ? Color(0xFF0F172A) : Color(0xFFFEFCF8),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xfff8e6da),
          ),
        ),
      );
    }

    /// Theme Colors
    final bool isDark = widget.isDarkMode;
    final Color bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFFEFCF8);
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF111827) : Color(0xfffdf4ee),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Color(0xFF1E293B), Color(0xFF374151)]
                      : [Color(0xfffdf4ee), Color(0xfff8e6da)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xfff8e6da),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${firstName.text} ${lastName.text}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ACCOUNT INFO
              buildCard(
                title: "Account Information",
                isDark: isDark,
                children: [
                  infoRow("First Name", firstName.text, textColor, Icons.person),
                  infoRow("Last Name", lastName.text, textColor, Icons.person_outline),
                  infoRow("Email", email.text, textColor, Icons.email),
                ],
              ),

              // PERSONAL INFO
              buildCard(
                title: "Personal Information",
                showEdit: true,
                isDark: isDark,
                onEdit: () {
                  showEditDialog(
                    title: "Edit Personal Information",
                    fields: [
                      _buildTextField(birthday, "Birthday", Icons.cake),
                      _buildTextField(gender, "Gender", Icons.person),
                      _buildTextField(emiratesId, "Emirates ID", Icons.badge),
                    ],
                    onSave: () {
                      updateSection({
                        "birthday": birthday.text,
                        "gender": gender.text,
                        "emiratesId": emiratesId.text,
                      });
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
                children: [
                  infoRow("Birthday", birthday.text, textColor, Icons.cake),
                  infoRow("Gender", gender.text, textColor, Icons.person),
                  infoRow("Emirates ID", emiratesId.text, textColor, Icons.badge),
                ],
              ),

              // CONTACT INFO
              buildCard(
                title: "Contact Information",
                showEdit: true,
                isDark: isDark,
                onEdit: () {
                  showEditDialog(
                    title: "Edit Contact Information",
                    fields: [
                      _buildTextField(address, "Address", Icons.home),
                      _buildTextField(country, "Country", Icons.flag),
                      _buildTextField(phone, "Phone", Icons.phone),
                    ],
                    onSave: () {
                      updateSection({
                        "address": address.text,
                        "country": country.text,
                        "phone": phone.text,
                      });
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
                children: [
                  infoRow("Address", address.text, textColor, Icons.home),
                  infoRow("Country", country.text, textColor, Icons.flag),
                  infoRow("Phone", phone.text, textColor, Icons.phone),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    final isDark = widget.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xfff8e6da)),
          filled: true,
          fillColor: isDark ? Color(0xFF374151) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xfff8e6da).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xfff8e6da)),
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }
}