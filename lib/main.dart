import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/screens/auth_check.dart';
import 'package:Outbox/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress DevTools connection warnings (harmless but noisy)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Filter out DevTools-related warnings
    if (details.exception.toString().contains('DevTools') ||
        details.exception.toString().contains('DWDS') ||
        details.exception.toString().contains('activeDevToolsServerAddress') ||
        details.exception.toString().contains('connectedVmServiceUri')) {
      // Silently ignore DevTools warnings
      return;
    }
    // Handle other errors normally
    FlutterError.presentError(details);
  };

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
        home: AuthCheck(),

      ),
    );
  }
}
