import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';   // ✅ IMPORTANT
// import 'package:khyate_b2b/screens/onboarding_screen.dart';
// import 'package:khyate_b2b/providers/cart_provider.dart';    // ✅ YOUR CART PROVIDER
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAuyK0gsU6P1iH2zBfLTEKgbjEZx3z4k90",
        authDomain: "b2bproject-b2c91.firebaseapp.com",
        projectId: "b2bproject-b2c91",
        storageBucket: "b2bproject-b2c91.appspot.com",
        messagingSenderId: "264918662033",
        appId: "1:264918662033:web:3029cf068709e859307830",
        measurementId: "G-QV1XRTFJBX",
      ),
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  } else {
    await Firebase.initializeApp();
  }

  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),     // ✅ PROVIDER INITIALIZED
        ),
      ],
      child: MaterialApp(
        title: 'Outbox',
        debugShowCheckedModeBanner: false,
        home: OnboardingScreen(),
      ),
    );
  }
}
