import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/master_data_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// Emirates ID TextInputFormatter for auto-formatting
class EmiratesIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 15 digits
    final limitedDigits = digitsOnly.length > 15 
        ? digitsOnly.substring(0, 15) 
        : digitsOnly;
    
    // Format as 784-YYYY-NNNNNNN-X
    // Format: 3 digits (784) - 4 digits (YYYY) - 7 digits (NNNNNNN) - 1 digit (X)
    String formatted = '';
    for (int i = 0; i < limitedDigits.length; i++) {
      // Add hyphen after 3rd digit (before 4th digit)
      if (i == 3) {
        formatted += '-';
      }
      // Add hyphen after 7th digit (before 8th digit)
      else if (i == 7) {
        formatted += '-';
      }
      // Add hyphen after 14th digit (before 15th digit)
      else if (i == 14) {
        formatted += '-';
      }
      formatted += limitedDigits[i];
    }
    
    // Calculate cursor position
    // Count hyphens before cursor position
    int cursorPosition = formatted.length;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emiratesIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController fitnessGoalsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? birthday;
  String? selectedGender;
  Map<String, dynamic>? selectedCountry; // Store country object with ID
  Map<String, dynamic>? selectedCity; // Store city object
  List<dynamic> countries = [];
  List<dynamic> cities = [];
  String phoneNumber = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _loadingCountries = false;
  bool _loadingCities = false;
  String message = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loadingCountries = true;
      message = ''; // Clear any previous messages
    });
    try {
      final countriesList = await MasterDataService().getAllCountries();
      setState(() {
        countries = countriesList;
        _loadingCountries = false;
        if (countriesList.isEmpty) {
          message = 'No countries found. Please contact support.';
        }
      });
    } catch (e) {
      setState(() {
        _loadingCountries = false;
        // Clean up error message - remove "Exception: " prefix if present
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        message = 'Failed to load countries: $errorMsg';
      });
      // Also print to console for debugging
      print('Error loading countries: $e');
    }
  }

  Future<void> _loadCities(String countryId) async {
    setState(() {
      _loadingCities = true;
      cities = [];
      selectedCity = null;
      cityController.clear();
    });
    try {
      final citiesList = await MasterDataService().getCitiesByCountry(countryId);
      setState(() {
        cities = citiesList;
        _loadingCities = false;
      });
    } catch (e) {
      setState(() {
        _loadingCities = false;
        message = 'Failed to load cities: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emiratesIdController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    countryController.dispose();
    cityController.dispose();
    fitnessGoalsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Validate Emirates ID
  String? _validateEmiratesId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Emirates ID';
    }
    
    // Remove hyphens and spaces for validation
    final digitsOnly = value.replaceAll(RegExp(r'[-\s]'), '');
    
    // Check length (must be 15 digits)
    if (digitsOnly.length != 15) {
      return 'Emirates ID must be 15 digits (format: 784-XXXX-XXXXXXX-X)';
    }
    
    // Check if it starts with 784 (UAE country code)
    if (!digitsOnly.startsWith('784')) {
      return 'Emirates ID must start with 784';
    }
    
    // Validate format: 784-YYYY-NNNNNNN-X
    // Check if formatted correctly (with hyphens) or just digits
    if (value.contains('-')) {
      final formatRegex = RegExp(r'^784-\d{4}-\d{7}-\d$');
      if (!formatRegex.hasMatch(value)) {
        return 'Invalid Emirates ID format. Expected: 784-XXXX-XXXXXXX-X';
      }
    }
    
    // Extract year (positions 4-7 in digitsOnly, which are indices 3-6)
    final yearStr = digitsOnly.substring(3, 7);
    final year = int.tryParse(yearStr);
    if (year == null || year < 1900 || year > DateTime.now().year) {
      return 'Invalid year in Emirates ID (must be between 1900 and ${DateTime.now().year})';
    }
    
    // Check for invalid characters (only digits and hyphens allowed)
    if (RegExp(r'[^\d-]').hasMatch(value)) {
      return 'Emirates ID can only contain digits and hyphens';
    }
    
    // Validate that all characters are digits (when hyphens removed)
    if (!RegExp(r'^\d{15}$').hasMatch(digitsOnly)) {
      return 'Emirates ID must contain only digits';
    }
    
    return null;
  }

  // Check if Emirates ID already exists
  Future<bool> _checkEmiratesIdDuplicate(String emiratesId) async {
    try {
      // TODO: Implement with your API
      // Remove hyphens for comparison
      final digitsOnly = emiratesId.replaceAll('-', '');
      // Check if any user has this Emirates ID using your API
      return false; // Stub - replace with actual API call
    } catch (e) {
      return false;
    }
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<bool> _checkPhoneDuplicate(String phone) async {
    try {
      // TODO: Implement with your API
      final normalized = _normalizePhone(phone);
      if (normalized.isEmpty) return false;
      // Check if phone exists using your API
      return false; // Stub - replace with actual API call
    } catch (_) {
      return false;
    }
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      message = '';
    });

    try {
      // Validate required fields
      if (firstNameController.text.trim().isEmpty) {
        setState(() {
          message = 'Please enter your first name';
          _isLoading = false;
        });
        return;
      }

      if (lastNameController.text.trim().isEmpty) {
        setState(() {
          message = 'Please enter your last name';
          _isLoading = false;
        });
        return;
      }

      if (selectedGender == null) {
        setState(() {
          message = 'Please select your gender';
          _isLoading = false;
        });
        return;
      }

      if (birthday == null) {
        setState(() {
          message = 'Please select your birthday';
          _isLoading = false;
        });
        return;
      }

      // Check for duplicate Emirates ID
      final emiratesId = emiratesIdController.text.trim();
      if (emiratesId.isNotEmpty) {
        final isDuplicate = await _checkEmiratesIdDuplicate(emiratesId);
        if (isDuplicate) {
          setState(() {
            message = 'This Emirates ID is already registered';
            _isLoading = false;
          });
          return;
        }
      }

      // Note: Phone number validation removed as it's not required in backend registration API

      // Calculate age from birthday
      int age = 0;
      if (birthday != null) {
        final today = DateTime.now();
        age = today.year - birthday!.year;
        if (today.month < birthday!.month || 
            (today.month == birthday!.month && today.day < birthday!.day)) {
          age--;
        }
      }

      // Validate country selection
      if (selectedCountry == null || selectedCountry!['_id'] == null) {
        setState(() {
          message = 'Please select a country';
          _isLoading = false;
        });
        return;
      }

      // Validate city selection
      if (selectedCity == null || cityController.text.trim().isEmpty) {
        setState(() {
          message = 'Please select a city';
          _isLoading = false;
        });
        return;
      }

      // Get country ID and city ID
      final countryId = selectedCountry!['_id'] ?? selectedCountry!['id'];
      final cityId = selectedCity!['_id'] ?? selectedCity!['id'];
      
      if (cityId == null) {
        setState(() {
          message = 'Please select a valid city';
          _isLoading = false;
        });
        return;
      }

      // Remove hyphens from Emirates ID
      final emiratesIdClean = emiratesId.replaceAll('-', '').replaceAll(' ', '');

      // Call API with all required fields matching backend API
      final user = await AuthService().signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        userRole: 3, // Customer role_id is 3
        country: countryId.toString(), // Country ID (ObjectId)
        city: cityId.toString(), // City ID (ObjectId)
        gender: selectedGender!,
        address: addressController.text.trim().isNotEmpty 
            ? addressController.text.trim() 
            : 'Not provided',
        emiratesId: emiratesIdClean,
        age: age,
      );
      
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          message = 'Registration failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // Clean up error message
        String errorMsg = e.toString();
        errorMsg = errorMsg.replaceAll('Exception: ', '');
        message = errorMsg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoColor = const Color(0xFF20C8B1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Logo section with #20c8b1 background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.04,
                    bottom: screenHeight * 0.06,
                  ),
                  decoration: BoxDecoration(
                    color: logoColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: logoColor.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
          child: Column(
            children: [
                      // Logo
                      Image.asset(
                        'assets/loginlogo.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us and start your fitness journey',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // First Name field
                        TextFormField(
                controller: firstNameController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter first name.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Last Name field
                        TextFormField(
                controller: lastNameController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter last name.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        TextFormField(
                controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        TextFormField(
                controller: passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter password.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: logoColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password field
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Confirm password.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: logoColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Birthday field
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: birthday ?? DateTime(1990, 1, 1),
                    firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: logoColor,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: const Color(0xFF1A2332),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                birthday = pickedDate;
                                birthdayController.text = DateFormat('MMM dd, yyyy').format(pickedDate);
                              });
                            }
                },
                child: AbsorbPointer(
                            child: TextFormField(
                    controller: birthdayController,
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                      hintText: 'Select your birthday',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                prefixIcon: Icon(
                                  Icons.cake_outlined,
                                  color: logoColor,
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: logoColor,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: logoColor,
                                    width: 2,
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
                        const SizedBox(height: 20),

                        // Gender field
              DropdownButtonFormField<String>(
                value: selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Select gender.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          items: ['Male', 'Female', 'Others']
                    .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: const TextStyle(
                                        color: Color(0xFF1A2332),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
              ),
                        const SizedBox(height: 20),

                        // Emirates ID field
                        TextFormField(
                controller: emiratesIdController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            EmiratesIdFormatter(),
                            FilteringTextInputFormatter.deny(RegExp(r'\s')), // Deny spaces only (formatter handles the rest)
                          ],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Emirates ID',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter Emirates ID.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red.shade400,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: _validateEmiratesId,
                        ),
                        const SizedBox(height: 20),

                        // Address field
                        TextFormField(
                controller: addressController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Address',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter address.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.home_outlined,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Country field
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedCountry,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: _loadingCountries ? 'Loading countries...' : 'Select country',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.flag_outlined,
                              color: logoColor,
                            ),
                            suffixIcon: _loadingCountries
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : Icon(
                                    Icons.arrow_drop_down,
                                    color: logoColor,
                                  ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          items: countries.map((country) {
                            final countryName = country['name'] ?? country['country_name'] ?? 'Unknown';
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: country,
                              child: Text(
                                countryName,
                                style: const TextStyle(
                                  color: Color(0xFF1A2332),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (country) {
                            if (country != null) {
                              setState(() {
                                selectedCountry = country;
                                countryController.text = country['name'] ?? country['country_name'] ?? '';
                                // Load cities for selected country
                                final countryId = country['_id'] ?? country['id'];
                                if (countryId != null) {
                                  _loadCities(countryId.toString());
                                }
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a country';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // City field
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedCity,
                          decoration: InputDecoration(
                            labelText: 'City',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: selectedCountry == null
                                ? 'Select country first'
                                : _loadingCities
                                    ? 'Loading cities...'
                                    : 'Select city',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: logoColor,
                            ),
                            suffixIcon: _loadingCities
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : Icon(
                                    Icons.arrow_drop_down,
                                    color: logoColor,
                                  ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                          items: cities.map((city) {
                            final cityName = city['name'] ?? city['city_name'] ?? 'Unknown';
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: city,
                              child: Text(
                                cityName,
                                style: const TextStyle(
                                  color: Color(0xFF1A2332),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: selectedCountry == null
                              ? null
                              : (city) {
                                  if (city != null) {
                                    setState(() {
                                      selectedCity = city;
                                      cityController.text = city['name'] ?? city['city_name'] ?? '';
                                    });
                                  }
                                },
                          validator: (value) {
                            if (selectedCountry == null) {
                              return 'Please select a country first';
                            }
                            if (value == null) {
                              return 'Please select a city';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone field
              IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter your phone number',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                initialCountryCode: 'AE',
                onChanged: (phone) => phoneNumber = phone.completeNumber,
                showCountryFlag: true,
              ),
                        const SizedBox(height: 20),

                        // Fitness Goals field
                        TextFormField(
                          controller: fitnessGoalsController,
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2332),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Fitness Goals (Optional)',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            hintText: 'Enter your fitness goals...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.fitness_center_outlined,
                              color: logoColor,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: logoColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error message
                        if (message.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Sign up button
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [logoColor, logoColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: logoColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : signUp,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
              const SizedBox(height: 16),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
              TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: logoColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
