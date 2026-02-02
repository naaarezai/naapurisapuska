import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'user_service.dart';
import '../models/user_model.dart';

/// Service to handle social authentication (Google, Apple)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Google Sign-In Configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  /// Returns UserCredential if successful, null otherwise
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile
      await _handleSocialLoginUser(
        userCredential,
        name: googleUser.displayName,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign in with Apple (iOS/macOS only)
  /// Returns UserCredential if successful, null otherwise
  Future<UserCredential?> signInWithApple() async {
    // Check if platform supports Apple Sign-In
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) {
      throw UnsupportedError(
          'Apple Sign-In is only supported on iOS and macOS');
    }

    try {
      // Check if Apple Sign-In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw UnsupportedError('Apple Sign-In is not available on this device');
      }

      // Request credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Extract name from Apple credential
      String? name;
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        name =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
      }

      // Create or update user profile
      await _handleSocialLoginUser(
        userCredential,
        name: name,
        email: appleCredential.email,
        photoUrl: null, // Apple doesn't provide photos
      );

      return userCredential;
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
      rethrow;
    }
  }

  /// Handle user creation/update after social login
  /// Creates a UserModel and saves to Firestore
  Future<void> _handleSocialLoginUser(
    UserCredential userCredential, {
    String? name,
    String? email, // Email is not stored in UserModel currently
    String? photoUrl,
  }) async {
    final user = userCredential.user;
    if (user == null) return;

    // Check if user already exists in Firestore
    final existingUser = await _userService.getUser(user.uid);

    if (existingUser == null) {
      // First time login - create new user
      final userModel = UserModel(
        id: user.uid,
        name: name ?? user.displayName ?? 'User',
        profileImageUrl: photoUrl ?? user.photoURL,
        createdAt: DateTime.now(),
        // Phone number is optional for social logins
        phoneNumber: user.phoneNumber,
      );

      await _userService.createOrUpdateUser(userModel);
    } else {
      // User exists - update profile if new information available
      bool needsUpdate = false;
      UserModel updatedUser = existingUser;

      // Only update if we have newer/better information
      if (photoUrl != null && existingUser.profileImageUrl != photoUrl) {
        updatedUser = updatedUser.copyWith(profileImageUrl: photoUrl);
        needsUpdate = true;
      }

      if (needsUpdate) {
        await _userService.createOrUpdateUser(updatedUser);
      }
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
