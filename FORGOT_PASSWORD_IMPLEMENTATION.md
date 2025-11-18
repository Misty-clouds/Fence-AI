# Forgot Password Implementation

## Overview
The forgot password feature has been successfully implemented in your Fence AI app. It allows users to reset their password via email.

## Files Added/Modified

### New Files Created:
1. **`lib/auth/pages/forgot_password.dart`** - Page where users enter their email to request a password reset
2. **`lib/auth/pages/reset_password.dart`** - Page where users enter their new password after clicking the email link

### Modified Files:
1. **`lib/auth/services/auth_service.dart`** - Added two new methods:
   - `resetPasswordForEmail(String email)` - Sends password reset email
   - `verifyOtpAndResetPassword()` - Verifies the token and updates the password

2. **`lib/auth/pages/sign_in.dart`** - Updated the "Forgot Password" link to navigate to the forgot password page

3. **`lib/auth/services/deeplink_service.dart`** - Added handling for password reset deep links

4. **`lib/main.dart`** - Added routes for `/forgot-password`, `/reset-password`, and `/sign-in`

## How It Works

### Step 1: User Requests Password Reset
1. User clicks "Forgot Password" on the sign-in page
2. User is taken to the forgot password page
3. User enters their email address
4. App calls `resetPasswordForEmail()` which sends a reset link to the user's email

### Step 2: User Receives Email
- Supabase sends an email with a magic link
- The link has format: `io.supabase.fenceai://reset-password?token=xxx&type=recovery`

### Step 3: Deep Link Handling
1. When user clicks the link in their email, the app opens
2. `DeepLinkService` intercepts the URL
3. It extracts the token and email from the URL
4. Navigates to the reset password page with these parameters

### Step 4: Password Reset
1. User enters and confirms their new password
2. App calls `verifyOtpAndResetPassword()` with the token, email, and new password
3. Supabase verifies the token and updates the password
4. User is redirected to the sign-in page

## Configuration Required

### Supabase Dashboard Setup
Make sure your Supabase project has the correct redirect URL configured:

1. Go to your Supabase project dashboard
2. Navigate to Authentication → URL Configuration
3. Add the redirect URL: `io.supabase.fenceai://reset-password`

### Deep Link Configuration
The deep link scheme `io.supabase.fenceai://` should already be configured in your:
- `android/app/src/main/AndroidManifest.xml` (for Android)
- `ios/Runner/Info.plist` (for iOS)

## Testing

### Test Locally:
1. Run the app: `flutter run`
2. Navigate to sign-in page
3. Click "Forgot Password"
4. Enter a test email address
5. Check the email inbox for the reset link
6. Click the link (it should open the app)
7. Enter a new password
8. Verify you can sign in with the new password

## Provider Access
The forgot password methods are accessible through the existing `authActionsProvider`:

```dart
final authService = ref.read(authActionsProvider);

// Send reset email
await authService.resetPasswordForEmail(email);

// Reset password with token
await authService.verifyOtpAndResetPassword(
  email: email,
  token: token,
  newPassword: newPassword,
);
```

## UI Features
- Clean, consistent UI matching your app's design system
- Loading states during async operations
- Form validation for email and password fields
- Password visibility toggle
- Success/error messages via SnackBar
- "Resend email" functionality
- Email sent confirmation screen

## Security Features
- Token-based verification (OTP)
- Secure password update through Supabase Auth
- Deep link validation
- Error handling for expired or invalid tokens
