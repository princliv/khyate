import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

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
  final profileImageUrl = TextEditingController();


  bool isLoading = true;
  bool _isDarkMode = false;
Country? selectedCountry;  
String selectedCountryName = "United Arab Emirates";
String selectedCountryCode = "+971";

bool phoneValid = true;
String fullPhone = "";
String? phoneValidationMessage;
int _profileImageCacheKey = DateTime.now().millisecondsSinceEpoch;


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
        // Ensure phoneCode doesn't already have a + sign
        String phoneCode = country.phoneCode.replaceAll('+', '');
        selectedCountryCode = "+$phoneCode";
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
  try {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      // Handle nested data structure
      final userData = user['data'] ?? user;
      
      profileImageUrl.text = userData['profile_image'] ?? '';
      firstName.text = userData['first_name'] ?? '';
      lastName.text = userData['last_name'] ?? '';
      email.text = userData['email'] ?? '';
      
      // Handle birthday - could be Date or string
      if (userData['birthday'] != null) {
        try {
          if (userData['birthday'] is String) {
            birthday.text = userData['birthday'];
          } else {
            // If it's a Date object, format it
            final dateStr = userData['birthday'].toString();
            birthday.text = dateStr.split('T')[0]; // Extract date part
          }
        } catch (e) {
          birthday.text = '';
        }
      }
      
      gender.text = userData['gender'] ?? '';
      emiratesId.text = userData['emirates_id'] ?? '';
      address.text = userData['address'] ?? '';
      
      // Handle country - could be ObjectId or populated object
      if (userData['country'] != null) {
        if (userData['country'] is Map) {
          country.text = userData['country']['name'] ?? '';
        } else {
          country.text = userData['country'].toString();
        }
      }
      
      // Handle phone number
      if (userData['phone_number'] != null) {
        phone.text = userData['phone_number'].toString();
      }
    }
  } catch (e) {
    print('Error loading profile: $e');
    // Continue with empty fields if API fails
  }

  _hydratePhoneForUi();
  _formatEmiratesIdForUi();
  setState(() => isLoading = false);
}


  void _formatEmiratesIdForUi() {
    final raw = emiratesId.text.replaceAll(RegExp(r'[^\d]'), '');
    if (raw.length == 15) {
      emiratesId.text = _formatEmiratesId(raw);
    }
  }

  String _formatEmiratesId(String digitsOnly) {
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 7 || i == 14) buffer.write('-');
      buffer.write(digitsOnly[i]);
    }
    return buffer.toString();
  }

  String? _validateEmiratesId(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[-\s]'), '');
    if (digitsOnly.length != 15) {
      return 'Emirates ID must be 15 digits';
    }
    if (!digitsOnly.startsWith('784')) {
      return 'Emirates ID must start with 784';
    }
    if (!RegExp(r'^\d{15}$').hasMatch(digitsOnly)) {
      return 'Emirates ID can only contain digits';
    }
    final yearStr = digitsOnly.substring(3, 7);
    final year = int.tryParse(yearStr);
    if (year == null || year < 1900 || year > DateTime.now().year) {
      return 'Invalid year in Emirates ID';
    }
    return null;
  }

  // Extract country code + local number (last 10 digits) for the phone field
  void _hydratePhoneForUi() {
    final storedPhone = phone.text.trim();
    if (storedPhone.isEmpty) {
      selectedCountryName = country.text.isNotEmpty ? country.text : selectedCountryName;
      return;
    }

    final cleaned = storedPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length <= 10) {
      phone.text = cleaned;
      fullPhone = '${selectedCountryCode.replaceAll('+', '')}$cleaned';
      selectedCountryName = country.text.isNotEmpty ? country.text : selectedCountryName;
      return;
    }

    final String localNumber = cleaned.substring(cleaned.length - 10);
    String codePart = cleaned.substring(0, cleaned.length - 10);
    if (!codePart.startsWith('+')) {
      codePart = '+$codePart';
    }

    phone.text = localNumber;
    fullPhone = '$codePart$localNumber';
    // Normalize codePart to ensure no double plus signs
    String normalizedCode = codePart.replaceAll('+', '');
    normalizedCode = '+$normalizedCode';
    selectedCountryCode = normalizedCode;
    // Update country name based on extracted country code, but prefer stored country name if available
    String countryNameFromCode = _getCountryNameFromCode(normalizedCode);
    selectedCountryName = country.text.isNotEmpty ? country.text : countryNameFromCode;
  }

  String _initialCountryIsoFromCode(String code) {
    // Normalize code to remove any double plus signs
    String normalizedCode = code.replaceAll('+', '');
    normalizedCode = '+$normalizedCode';
    
    switch (normalizedCode) {
      case '+91':
        return 'IN';
      case '+971':
        return 'AE';
      default:
        return 'AE';
    }
  }

  String _getCountryNameFromCode(String code) {
    // Normalize code to remove any double plus signs
    String normalizedCode = code.replaceAll('+', '');
    normalizedCode = '+$normalizedCode';
    
    switch (normalizedCode) {
      case '+91':
        return 'India';
      case '+971':
        return 'United Arab Emirates';
      default:
        return 'United Arab Emirates';
    }
  }

  Future<bool> _emiratesIdExistsForAnotherUser(String digitsOnly) async {
    // TODO: Implement with your API
    // Check if Emirates ID exists for another user
    return false; // Stub - replace with actual API call
  }

  String _getImageUrlWithCacheBuster(String url) {
    if (url.isEmpty) return url;
    try {
      final uri = Uri.parse(url);
      final separator = uri.queryParameters.isEmpty ? '?' : '&';
      return '$url${separator}cache=${_profileImageCacheKey}';
    } catch (e) {
      // If URL parsing fails, append cache parameter directly
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}cache=${_profileImageCacheKey}';
    }
  }

  Future<void> updateSection(Map<String, dynamic> updates) async {
    try {
      // Convert updates to match API format
      final profileService = UserProfileService();
      
      await profileService.updateUserProfile(
        firstName: updates['first_name'] ?? updates['firstName'],
        lastName: updates['last_name'] ?? updates['lastName'],
        email: updates['email'],
        phoneNumber: updates['phone_number'] ?? updates['phone'],
        address: updates['address'],
        country: updates['country'],
        birthday: updates['birthday'],
        gender: updates['gender'],
        profileImage: updates['profile_image'] ?? updates['profileImage'],
        emiratesId: updates['emirates_id'] ?? updates['emiratesId'],
      );
      
      // Reload profile to get updated data
      await loadProfile();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully"),
          backgroundColor: const Color(0xFF21B998),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showProfileImageEditDialog(BuildContext context) {
    final isDark = _isDarkMode;
    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color textColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);
    final Color fieldBg = isDark ? const Color(0xFF2D3748) : Colors.white;
    final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color focusColor = const Color(0xFF21B998);

    final imageUrlController = TextEditingController(text: profileImageUrl.text);

    showDialog(
      context: context,
      builder: (_) {
        // Get available height considering keyboard
        final mediaQuery = MediaQuery.of(context);
        final availableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
        final maxDialogHeight = availableHeight * 0.85; // Use 85% of available height
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: maxDialogHeight,
            ),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title - fixed at top
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Text(
                    "Edit Profile Image",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Scrollable content area
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: imageUrlController,
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Profile Image URL",
                        prefixIcon: Icon(Icons.image, color: focusColor),
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
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons - fixed at bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final newUrl = imageUrlController.text.trim();
                          profileImageUrl.text = newUrl;
                          await updateSection({
                            "profile_image": newUrl,
                          });
                          if (mounted) {
                            setState(() {
                              _profileImageCacheKey = DateTime.now().millisecondsSinceEpoch;
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: focusColor,
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
                ),
              ],
            ),
          ),
        );
      },
    );
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
            // Get available height considering keyboard
            final mediaQuery = MediaQuery.of(context);
            final availableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
            final maxDialogHeight = availableHeight * 0.85; // Use 85% of available height
            
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxDialogHeight,
                ),
                decoration: BoxDecoration(
                  color: dialogBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - fixed at top
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Scrollable content area
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: fields,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons - fixed at bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
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
                    ),
                  ],
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (showEdit) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: InkWell(
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
                      ),
                    ),
                  ],
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
  final isDark = _isDarkMode;
  final Color fieldBg = isDark ? const Color(0xFF2D3748) : Colors.white;
  final Color textColor = isDark ? Colors.white : const Color(0xFF1A2332);
  final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
  final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);
  final Color focusColor = const Color(0xFF21B998);

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
      TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: "Enter phone number",
          prefixIcon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              selectedCountryCode,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
        onChanged: (value) {
          setState(() {
            final numberWithoutCode = value.trim();

            // Compose full phone with selected country code from above picker
            final cleanCode = selectedCountryCode.replaceAll('+', '');
            fullPhone = '+$cleanCode$numberWithoutCode';

            // Strict validation: require exactly 10 digits (common mobile length)
            if (numberWithoutCode.isEmpty) {
              phoneValid = false;
              phoneValidationMessage = "Phone number is required";
            } else if (numberWithoutCode.length != 10) {
              phoneValid = false;
              phoneValidationMessage = "Phone number must be 10 digits";
            } else {
              phoneValid = true;
              phoneValidationMessage = null;
            }
          });
        },
      ),

      if (phone.text.isNotEmpty && phoneValidationMessage != null)
        Text(
          phoneValid ? "✔ Valid number" : "✖ $phoneValidationMessage",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: phoneValid ? Colors.green : Colors.red,
            fontSize: 12,
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
        leadingWidth: Navigator.of(context).canPop() ? 64 : 200,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SizedBox(
                  height: 35,
                  width: 140,
                  child: Image.asset(
                    'assets/company.png',
                    fit: BoxFit.contain,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return frame != null ? child : const SizedBox();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image,
                          color: Colors.white, size: 35);
                    },
                  ),
                ),
              ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
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
                    Stack(
                      clipBehavior: Clip.none,
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
                          child: ClipOval(
                            child: profileImageUrl.text.isEmpty
                                ? Icon(Icons.person, size: 40, color: Colors.white)
                                : Image.network(
                                    _getImageUrlWithCacheBuster(profileImageUrl.text),
                                    key: ValueKey('${profileImageUrl.text}_$_profileImageCacheKey'),
                                    fit: BoxFit.cover,
                                    cacheWidth: 160,
                                    cacheHeight: 160,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [const Color(0xFF21B998), const Color(0xFF0097B2)],
                                          ),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [const Color(0xFF21B998), const Color(0xFF0097B2)],
                                          ),
                                        ),
                                        child: Icon(Icons.person, size: 40, color: Colors.white),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        // Pencil edit button at bottom right
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showProfileImageEditDialog(context),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF21B998),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  infoRow("Profile Image URL", profileImageUrl.text, textColor, Icons.image, isDark),

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
                      _buildEmiratesIdField(),
                    ],
                    onSave: () async {
                      final validation = _validateEmiratesId(emiratesId.text);
                      if (validation != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(validation),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final digitsOnly = emiratesId.text.replaceAll('-', '');
                      final formattedDisplay = _formatEmiratesId(digitsOnly);
                      final existsElsewhere =
                          await _emiratesIdExistsForAnotherUser(digitsOnly);
                      if (existsElsewhere) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('This Emirates ID is already registered'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      await updateSection({
                        "birthday": birthday.text,
                        "gender": gender.text,
                        "emirates_id": digitsOnly,
                      });
                      emiratesId.text = formattedDisplay;
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
  // Ensure phone is hydrated before opening dialog
  _hydratePhoneForUi();
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
      // Final validation before saving: require exactly 10 digits
      String numberWithoutCode = phone.text.replaceAll(RegExp(r'[^\d]'), '');
      bool isNumberValid = numberWithoutCode.length == 10 &&
                          RegExp(r'^\d+$').hasMatch(numberWithoutCode);
      
      if (!isNumberValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Phone number must be 10 digits"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update text values for UI
      country.text = selectedCountryName;
      // Store full phone number in phone.text for database
      phone.text = fullPhone;

      await updateSection({
        "phone": fullPhone,
        "country": selectedCountryName,
        "address": address.text,
      });

      // Re-hydrate phone to extract local number for display
      _hydratePhoneForUi();
      Navigator.pop(context);
      setState(() {});
    },
  );
},

  children: [
    infoRow("Address", address.text, textColor, Icons.home, isDark),
    infoRow("Country", country.text, textColor, Icons.flag, isDark),
    infoRow("Phone", fullPhone.isNotEmpty ? fullPhone : phone.text, textColor, Icons.phone, isDark),
  ],
),

              // SETTINGS & SECURITY
              buildCard(
                title: "Settings & Security",
                isDark: isDark,
                children: [
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: const Color(0xFF21B998)),
                    title: Text("Change Password", style: TextStyle(color: textColor)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: secondaryTextColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
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

  Widget _buildEmiratesIdField() {
    final isDark = _isDarkMode;
    final Color fieldBg = isDark ? const Color(0xFF2D3748) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final Color labelColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    final Color borderColor = isDark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);
    final Color focusColor = const Color(0xFF21B998);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: emiratesId,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _EmiratesIdFormatter()],
        keyboardType: TextInputType.number,
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          labelText: "Emirates ID",
          hintText: "784-XXXX-XXXXXXX-X",
          prefixIcon: Icon(Icons.badge, color: focusColor),
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
                // Ensure phoneCode doesn't already have a + sign
                String phoneCode = c.phoneCode.replaceAll('+', '');
                selectedCountryCode = "+$phoneCode";
                // Recompute full phone with the selected country code
                final numberWithoutCode = phone.text.trim();
                fullPhone = '$selectedCountryCode$numberWithoutCode';
                // Reset validation when country changes
                phoneValid = true;
                phoneValidationMessage = null;
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

class _EmiratesIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limited = digitsOnly.length > 15 ? digitsOnly.substring(0, 15) : digitsOnly;

    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 7 || i == 14) buffer.write('-');
      buffer.write(limited[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}