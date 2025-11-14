import 'package:fence_ai/auth/pages/authgate.dart';
import 'package:fence_ai/auth/pages/sign_up.dart';
import 'package:fence_ai/auth/services/deeplink_service.dart';
import 'package:fence_ai/view/pages/onboarding/role_selection.dart';
import 'package:fence_ai/constants/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    // Initialize deep links after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkService.initialize(context);
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fence AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        '/role-selection': (context) => const RoleSelectionPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}

