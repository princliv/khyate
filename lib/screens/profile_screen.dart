import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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
  bool _isDarkMode = false;
Country? selectedCountry;  
String selectedCountryName = "United Arab Emirates";
String selectedCountryCode = "+971";

bool phoneValid = true;
String fullPhone = "";


  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    loadProfile();
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = _isDarkMode;
    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color textColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'You will need to sign in again to access your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleLogout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Logout'),
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
  void pickCountry() {
  showCountryPicker(
    context: context,
    showPhoneCode: true,
    onSelect: (Country country) {
      setState(() {
        selectedCountryCode = "+${country.phoneCode}";
        selectedCountryName = country.name;
      });
    },
  );
}


  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().signOut();
    context.read<CartProvider>().clearCart();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      
      // Load from Firestore if available
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
      
      // If firstName, lastName, or email are empty, try to get from Firebase Auth user object
      if (user != null) {
        if (firstName.text.isEmpty || lastName.text.isEmpty) {
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            final nameParts = user.displayName!.trim().split(' ');
            if (firstName.text.isEmpty && nameParts.isNotEmpty) {
              firstName.text = nameParts[0];
            }
            if (lastName.text.isEmpty && nameParts.length > 1) {
              lastName.text = nameParts.sublist(1).join(' ');
            }
          }
        }
        
        if (email.text.isEmpty && user.email != null && user.email!.isNotEmpty) {
          email.text = user.email!;
        }
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
            content: const Text("Profile updated"),
            backgroundColor: const Color(0xFF21B998),
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
    final isDark = _isDarkMode;
    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A2332);
    
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: dialogBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...fields,
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark ? Colors.white70 : const Color(0xFF4A5568),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21B998),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text("Save Changes"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget infoRow(String label, String value, Color textColor, IconData icon, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF2D3748) : Colors.white;
    final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color valueColor = value.isNotEmpty 
        ? textColor 
        : (isDark ? Colors.white38 : Colors.grey[500]!);
    final Color iconBg = isDark 
        ? const Color(0xFF21B998).withOpacity(0.2) 
        : const Color(0xFF21B998).withOpacity(0.15);
    final Color iconColor = isDark ? const Color(0xFF21B998) : const Color(0xFF0097B2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF3A4555) 
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
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
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.isNotEmpty ? value : "Not set",
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color borderColor = isDark 
        ? const Color(0xFF3A4555) 
        : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (showEdit)
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF21B998), const Color(0xFF0097B2)]
                                : [const Color(0xFF21B998), const Color(0xFF0097B2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF21B998).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
Widget buildPhoneField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Phone Number",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 10),

      IntlPhoneField(
        controller: phone,
        initialCountryCode: 'AE',
        decoration: InputDecoration(
          hintText: "Enter phone number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        onChanged: (value) {
          setState(() {
            fullPhone = value.completeNumber;
            phoneValid = value.isValidNumber();
          });
        },
      ),

      if (phone.text.isNotEmpty)
        Text(
          phoneValid ? "✔ Valid number" : "✖ Invalid number",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: phoneValid ? Colors.green : Colors.red,
          ),
        ),
    ],
  );
}



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFEFCF8),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF21B998),
          ),
        ),
      );
    }

    /// Theme Colors with better contrast
    final bool isDark = _isDarkMode;
    final Color bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFFEFCF8);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    const Color barColor = Color(0xFF111827);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: barColor,
        elevation: 0,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: SizedBox(
            height: 35,
            width: 140,
            child: Image.asset(
              'assets/company.png',
              fit: BoxFit.contain,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return frame != null ? child : const SizedBox();
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, color: Colors.white, size: 35);
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              // Already on profile page
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _showLogoutConfirmation(context),
          ),
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
              color: Colors.white,
            ),
            tooltip: 'Toggle theme',
            onPressed: _toggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header with better contrast
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF1E293B), const Color(0xFF2D3748)]
                      : [Colors.white, const Color(0xFFF7FAFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [const Color(0xFF21B998), const Color(0xFF0097B2)],
                        ),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF21B998).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${firstName.text} ${lastName.text}".trim().isEmpty 
                                ? "User" 
                                : "${firstName.text} ${lastName.text}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email.text.isEmpty ? "No email" : email.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
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
                  infoRow("First Name", firstName.text, textColor, Icons.person, isDark),
                  infoRow("Last Name", lastName.text, textColor, Icons.person_outline, isDark),
                  infoRow("Email", email.text, textColor, Icons.email, isDark),
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
                      _buildDatePickerField(),
                      _buildGenderRadioButtons(),
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
                  infoRow(
                    "Birthday",
                    birthday.text.isEmpty
                        ? birthday.text
                        : (() {
                            try {
                              return DateFormat('MMM dd, yyyy').format(
                                DateFormat('yyyy-MM-dd').parse(birthday.text),
                              );
                            } catch (e) {
                              return birthday.text;
                            }
                          })(),
                    textColor,
                    Icons.cake,
                    isDark,
                  ),
                  infoRow("Gender", gender.text, textColor, Icons.person, isDark),
                  infoRow("Emirates ID", emiratesId.text, textColor, Icons.badge, isDark),
                ],
              ),

              // CONTACT INFO
// CONTACT INFO
buildCard(
  title: "Contact Information",
  showEdit: true,
  isDark: isDark,
  onEdit: () {
  showEditDialog(
    title: "Edit Contact Information",
    fields: [
      StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            children: [
              buildCountryPickerField(setDialogState),
              const SizedBox(height: 20),
              buildPhoneField(),
              const SizedBox(height: 20),
              _buildTextField(address, "Address", Icons.location_on),
            ],
          );
        },
      )
    ],
    onSave: () async {
      if (!phoneValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid phone number"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update text values for UI
      country.text = selectedCountryName;
      phone.text = fullPhone;

      await updateSection({
        "phone": fullPhone,
        "country": selectedCountryName,
        "address": address.text,
      });

      Navigator.pop(context);
      setState(() {});
    },
  );
},

  children: [
    infoRow("Address", address.text, textColor, Icons.home, isDark),
    infoRow("Country", country.text, textColor, Icons.flag, isDark),
    infoRow("Phone", phone.text, textColor, Icons.phone, isDark),
  ],
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    final isDark = _isDarkMode;
    final Color fieldBg = isDark ? const Color(0xFF2D3748) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);
    final Color focusColor = const Color(0xFF21B998);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: focusColor),
          filled: true,
          fillColor: fieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusColor, width: 2),
          ),
          labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
Widget buildCountryPickerField(StateSetter setDialogState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Country",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 10),

      InkWell(
        onTap: () {
          showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (Country c) {
              setDialogState(() {
                selectedCountry = c;
                selectedCountryName = c.name;
                selectedCountryCode = "+${c.phoneCode}";
              });
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedCountryName,
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),

      const SizedBox(height: 10),

      Text(
        "Code: $selectedCountryCode",
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}


  Widget _buildDatePickerField() {
    final isDark = _isDarkMode;
    final Color fieldBg = isDark ? const Color(0xFF2D3748) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);
    final Color focusColor = const Color(0xFF21B998);

    DateTime? selectedDate;
    if (birthday.text.isNotEmpty) {
      try {
        selectedDate = DateFormat('yyyy-MM-dd').parse(birthday.text);
      } catch (e) {
        // Try alternative formats if needed
        try {
          selectedDate = DateFormat('MM/dd/yyyy').parse(birthday.text);
        } catch (e2) {
          selectedDate = null;
        }
      }
    }

    return StatefulBuilder(
      builder: (context, setDialogState) {
        String displayText = birthday.text.isEmpty
            ? "Select your birthday"
            : (() {
                try {
                  return DateFormat('MMM dd, yyyy').format(
                    DateFormat('yyyy-MM-dd').parse(birthday.text),
                  );
                } catch (e) {
                  return birthday.text;
                }
              })();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: focusColor,
                        onPrimary: Colors.white,
                        surface: isDark ? const Color(0xFF1E293B) : Colors.white,
                        onSurface: textColor,
                      ),
                      dialogBackgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                birthday.text = DateFormat('yyyy-MM-dd').format(picked);
                setDialogState(() {});
                setState(() {});
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake, color: focusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Birthday",
                          style: TextStyle(
                            fontSize: 12,
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 16,
                            color: birthday.text.isEmpty ? labelColor : textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.calendar_today, color: focusColor, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderRadioButtons() {
    final isDark = _isDarkMode;
    final Color fieldBg = isDark ? const Color(0xFF2D3748) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);
    final Color focusColor = const Color(0xFF21B998);

    return StatefulBuilder(
      builder: (context, setDialogState) {
        String selectedGender = gender.text;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: focusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 12,
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                title: Text(
                  "Male",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: "Male",
                groupValue: selectedGender,
                activeColor: focusColor,
                onChanged: (String? value) {
                  gender.text = value ?? "";
                  setDialogState(() {});
                  setState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: Text(
                  "Female",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: "Female",
                groupValue: selectedGender,
                activeColor: focusColor,
                onChanged: (String? value) {
                  gender.text = value ?? "";
                  setDialogState(() {});
                  setState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: Text(
                  "Others",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: "Others",
                groupValue: selectedGender,
                activeColor: focusColor,
                onChanged: (String? value) {
                  gender.text = value ?? "";
                  setDialogState(() {});
                  setState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }
}