import 'package:fence_ai/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  StreamSubscription? _sub;
  final AuthService _authService = AuthService();
  final _appLinks = AppLinks();

  /// Initialize deep link handling
  Future<void> initialize(BuildContext context) async {
    // Handle initial link if app was opened via deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri, context);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen to incoming links while app is running
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri, context);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Handle deep link navigation
  Future<void> _handleDeepLink(Uri uri, BuildContext context) async {
    try {
      // Check if this is an OAuth callback
      if (uri.path == '/login-callback') {
        await _authService.handleOAuthCallback(uri);
        
        // Navigate to home after successful OAuth
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Dispose deep link subscription
  void dispose() {
    _sub?.cancel();
  }
}
