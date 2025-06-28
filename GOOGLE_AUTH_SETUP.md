# Google Authentication Setup Guide

This guide will help you set up Google Authentication in the Bidout Flutter app.

## Prerequisites

1. A Google Cloud Console project
2. Google Sign-In configured for your project
3. OAuth 2.0 credentials created

## Step 1: Google Cloud Console Setup

### 1.1 Create or Select a Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 1.2 Enable Google Sign-In API
1. In the Google Cloud Console, navigate to "APIs & Services" > "Library"
2. Search for "Google Sign-In API" or "Google+ API"
3. Click on it and press "Enable"

### 1.3 Configure OAuth Consent Screen
1. Go to "APIs & Services" > "OAuth consent screen"
2. Choose "External" user type (or "Internal" if using Google Workspace)
3. Fill in the required information:
   - App name: "Bidout"
   - User support email: Your email
   - App logo: Optional
   - App domain: Your app's domain
   - Developer contact information: Your email
4. Add scopes:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
5. Save and continue

### 1.4 Create OAuth 2.0 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Create credentials for each platform:

#### For Web Application (Required for all platforms)
- Application type: Web application
- Name: "Bidout Web Client"
- Authorized JavaScript origins: `http://localhost` (for development)
- Authorized redirect URIs: Not required for this setup
- **Save the Client ID - you'll need this for mobile configuration**

#### For Android (Optional, but recommended)
- Application type: Android
- Name: "Bidout Android"
- Package name: Your app's package name (e.g., `com.yourcompany.bidout`)
- SHA-1 certificate fingerprint: Get this by running:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

#### For iOS (Optional, but recommended)
- Application type: iOS
- Name: "Bidout iOS"
- Bundle ID: Your app's bundle identifier (e.g., `com.yourcompany.bidout`)

## Step 2: Flutter App Configuration

### 2.1 Android Configuration

1. **Update package name** (if needed):
   - In `android/app/build.gradle`, update the `applicationId`
   - Make sure it matches what you used in Google Cloud Console

2. **Configure strings.xml**:
   - Open `android/app/src/main/res/values/strings.xml`
   - Replace `YOUR_GOOGLE_OAUTH_WEB_CLIENT_ID` with your **Web Client ID** from Google Cloud Console:
   ```xml
   <string name="default_web_client_id">123456789-abcdefghijklmnop.apps.googleusercontent.com</string>
   ```

3. **Add SHA-1 fingerprint** (for production):
   - Generate your release keystore SHA-1 fingerprint
   - Add it to your Android OAuth client in Google Cloud Console

### 2.2 iOS Configuration

1. **Update bundle identifier** (if needed):
   - In Xcode, open `ios/Runner.xcworkspace`
   - Update the bundle identifier in project settings
   - Make sure it matches what you used in Google Cloud Console

2. **Configure Info.plist**:
   - Open `ios/Runner/Info.plist`
   - Replace `com.yourcompany.bidout` with your actual bundle identifier:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLName</key>
       <string>YOUR_ACTUAL_BUNDLE_ID</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>YOUR_ACTUAL_BUNDLE_ID</string>
       </array>
     </dict>
   </array>
   ```

3. **Add GoogleService-Info.plist** (Optional but recommended):
   - Download `GoogleService-Info.plist` from Firebase Console (if using Firebase)
   - Add it to `ios/Runner/` directory in Xcode

### 2.3 Backend Configuration

Make sure your backend (Laravel) is configured with the same Google OAuth credentials:

1. **Update `.env` file**:
   ```env
   GOOGLE_CLIENT_ID=your_web_client_id_here
   GOOGLE_CLIENT_SECRET=your_client_secret_here
   ```

2. **Update `config/services.php`**:
   ```php
   'google' => [
       'client_id' => env('GOOGLE_CLIENT_ID'),
       'client_secret' => env('GOOGLE_CLIENT_SECRET'),
       'redirect' => env('GOOGLE_REDIRECT_URL'),
   ],
   ```

## Step 3: Testing

### 3.1 Development Testing
1. Run your Flutter app in debug mode
2. Try the Google Sign-In functionality
3. Check that the user is properly authenticated and redirected

### 3.2 Production Preparation
1. Generate production keystore for Android
2. Add production SHA-1 fingerprint to Google Cloud Console
3. Update OAuth client settings for production domains
4. Test on physical devices

## Common Issues and Solutions

### 1. "Sign in failed" Error
- **Cause**: Incorrect OAuth client configuration
- **Solution**: Double-check your client IDs and make sure they match between Google Cloud Console and your app configuration

### 2. "Network Error" 
- **Cause**: API not enabled or quota exceeded
- **Solution**: Enable Google Sign-In API in Google Cloud Console and check quotas

### 3. "Package name/Bundle ID mismatch"
- **Cause**: The package name in your app doesn't match what's configured in Google Cloud Console
- **Solution**: Make sure package names match exactly

### 4. "SHA-1 fingerprint not found" (Android)
- **Cause**: SHA-1 fingerprint not added to Google Cloud Console
- **Solution**: Add your debug and release SHA-1 fingerprints to the Android OAuth client

### 5. "Invalid audience" Error
- **Cause**: Wrong client ID being used
- **Solution**: Make sure you're using the **Web Client ID** in your `strings.xml`, not the Android client ID

## Security Notes

1. **Never commit sensitive credentials** to version control
2. **Use environment variables** for client secrets
3. **Implement proper token validation** on the backend
4. **Use HTTPS** in production
5. **Regularly rotate credentials** for security

## Additional Resources

- [Google Sign-In for Flutter Documentation](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)

---

**Note**: Remember to replace all placeholder values with your actual project-specific values before deploying to production. 