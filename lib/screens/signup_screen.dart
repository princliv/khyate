import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emiratesIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  DateTime? birthday;
  String? selectedGender;
  Country? selectedCountry;
  String phoneNumber = '';

  String message = '';

  Future<void> signUp() async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'birthday': birthday != null ? birthday!.toIso8601String().split('T')[0] : '',
          'gender': selectedGender ?? '',
          'emiratesId': emiratesIdController.text,
          'address': addressController.text,
          'country': selectedCountry != null ? selectedCountry!.name : '',
          'flagEmoji': selectedCountry != null ? selectedCountry!.flagEmoji : '',
          'phone': phoneNumber,
        });
        setState(() => message = "Sign up successful!");
      }
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF8),
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2332)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(DateTime.now().year - 10),
                  );
                  if (pickedDate != null) setState(() => birthday = pickedDate);
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                      hintText: birthday == null
                          ? 'Select date'
                          : '${birthday!.day}/${birthday!.month}/${birthday!.year}',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
              ),
              TextField(
                controller: emiratesIdController,
                decoration: const InputDecoration(labelText: 'Emirates ID'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (Country country) {
                      setState(() => selectedCountry = country);
                    },
                  );
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Country',
                      hintText: selectedCountry == null
                          ? 'Select country'
                          : '${selectedCountry!.flagEmoji} ${selectedCountry!.name}',
                      suffixIcon: const Icon(Icons.flag),
                    ),
                  ),
                ),
              ),
              IntlPhoneField(
                decoration: const InputDecoration(labelText: 'Phone'),
                initialCountryCode: selectedCountry?.countryCode ?? 'AE',
                onChanged: (phone) => phoneNumber = phone.completeNumber,
                showCountryFlag: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A572),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Sign Up', style: TextStyle(color: Color(0xFF1A2332))),
              ),
              const SizedBox(height: 8),
              Text(message),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
