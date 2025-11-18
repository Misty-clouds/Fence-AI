# OAuth Setup Guide for Fence AI

This guide explains the OAuth authentication setup for Google and Apple sign-in with deep linking.

## Features Implemented

- ✅ Google OAuth Sign-in
- ✅ Apple OAuth Sign-in
- ✅ Deep linking for OAuth callbacks
- ✅ Automatic session handling after OAuth
- ✅ Cross-platform support (iOS & Android)

## Setup Instructions

### 1. Supabase Configuration

In your Supabase dashboard:

1. Go to **Authentication** > **Providers**
2. Enable **Google** provider:
   - Add your Google Client ID
   - Add your Google Client Secret
   - Set redirect URL: `io.supabase.fenceai://login-callback`

3. Enable **Apple** provider:
   - Add your Apple Service ID
   - Add your Apple Team ID
   - Add your Apple Key ID
   - Upload your Apple Private Key
   - Set redirect URL: `io.supabase.fenceai://login-callback`

### 2. Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Google+ API**
4. Create OAuth 2.0 credentials:
   - **Android**: Add SHA-1 fingerprint and package name
   - **iOS**: Add iOS bundle ID
   - **Web**: Add authorized redirect URIs

### 3. Apple Sign-In Setup

1. Go to [Apple Developer](https://developer.apple.com/)
2. Create an App ID with Sign in with Apple capability
3. Create a Services ID
4. Create a Key with Sign in with Apple capability
5. Configure Return URLs in Services ID settings

### 4. Deep Link Configuration

#### Android
The `AndroidManifest.xml` has been configured with:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.supabase.fenceai"
        android:host="login-callback" />
</intent-filter>
```

#### iOS
The `Info.plist` has been configured with:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.fenceai</string>
        </array>
    </dict>
</array>
```

## Usage

### In Your App

The OAuth buttons are already integrated in the `SignUpPage`:

```dart
// Google Sign-in
ElevatedButton(
  onPressed: () => _handleGoogleSignIn(context, ref),
  child: Text('Continue with Google'),
)

// Apple Sign-in
ElevatedButton(
  onPressed: () => _handleAppleSignIn(context, ref),
  child: Text('Continue with Apple'),
)
```

### Authentication Flow

1. User taps "Continue with Google" or "Continue with Apple"
2. App opens OAuth provider's login page in browser
3. User authenticates with provider
4. Provider redirects to: `io.supabase.fenceai://login-callback?token=...`
5. Deep link handler catches the callback
6. Session is established automatically
7. User is navigated to home screen

### Services Used

- **AuthService**: Handles OAuth sign-in methods
- **DeepLinkService**: Manages deep link callbacks
- **AuthProvider**: Provides state management for authentication

## Testing

### Test Deep Links

#### Android
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "io.supabase.fenceai://login-callback" \
  com.example.fence_ai
```

#### iOS
```bash
xcrun simctl openurl booted "io.supabase.fenceai://login-callback"
```

## Troubleshooting

### Google Sign-in Issues
- Verify SHA-1 fingerprint matches your debug/release keystore
- Check package name in Google Console matches your app
- Ensure Google+ API is enabled

### Apple Sign-in Issues
- Verify Bundle ID matches Services ID
- Check all certificates and keys are valid
- Ensure Return URLs are correctly configured

### Deep Link Issues
- Test deep links using terminal commands above
- Check `adb logcat` (Android) or Console.app (iOS) for errors
- Verify URL scheme matches exactly in all configurations

## Dependencies Added

```yaml
dependencies:
  app_links: ^6.3.2  # For deep link handling
  supabase_flutter: ^2.9.1  # Already included
```

## Files Modified

1. `/lib/auth/services/auth_service.dart` - Added OAuth methods
2. `/lib/auth/services/deeplink_service.dart` - New deep link handler
3. `/lib/auth/providers/auth_provider.dart` - Added OAuth providers
4. `/lib/auth/pages/sign_up.dart` - Integrated OAuth buttons
5. `/lib/main.dart` - Initialize deep link service
6. `/android/app/src/main/AndroidManifest.xml` - Deep link config
7. `/ios/Runner/Info.plist` - Deep link config
8. `/pubspec.yaml` - Added app_links dependency

## Security Notes

- Never commit OAuth credentials to version control
- Store sensitive keys in environment variables
- Use different OAuth credentials for debug/release builds
- Implement proper error handling for production
- Consider adding rate limiting for OAuth attempts

## Next Steps

1. Get OAuth credentials from Google and Apple
2. Configure Supabase dashboard with credentials
3. Test on physical devices (OAuth may not work on emulators)
4. Add loading states for better UX
5. Implement proper error handling
6. Add analytics for OAuth success/failure rates
