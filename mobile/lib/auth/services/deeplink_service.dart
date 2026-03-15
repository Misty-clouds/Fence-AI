import 'package:fence_ai/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:convert';

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
      // Check if this is a password reset callback
      else if (uri.path == '/reset-password') {
        // Extract token and type from the fragment
        final token = uri.queryParameters['token'] ?? 
                     uri.fragment.split('&')
                        .firstWhere((e) => e.startsWith('token='), 
                                   orElse: () => '')
                        .replaceFirst('token=', '');
        
        final type = uri.queryParameters['type'] ??
                    uri.fragment.split('&')
                        .firstWhere((e) => e.startsWith('type='), 
                                   orElse: () => '')
                        .replaceFirst('type=', '');
        
        // Get email from access_token if available
        String? email;
        final accessToken = uri.fragment.split('&')
                               .firstWhere((e) => e.startsWith('access_token='), 
                                          orElse: () => '')
                               .replaceFirst('access_token=', '');
        
        if (accessToken.isNotEmpty) {
          // Decode JWT to get email (simplified)
          try {
            final payload = accessToken.split('.')[1];
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final Map<String, dynamic> data = jsonDecode(decoded);
            email = data['email'];
          } catch (e) {
            debugPrint('Error decoding token: $e');
          }
        }
        
        if (context.mounted && token.isNotEmpty && type == 'recovery') {
          // Navigate to reset password page with token
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/reset-password',
            (route) => false,
            arguments: {'email': email, 'token': token},
          );
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
