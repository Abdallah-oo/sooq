import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleSignInProvider with ChangeNotifier {

  final googleSignIn = GoogleSignIn(
    clientId:kIsWeb ? '827890161771-3n2g07u1v280a29q28qjfsb2s4sselsk.apps.googleusercontent.com' : null,
  );

  GoogleSignInAccount? _googleUser;
  GoogleSignInAccount? get user => _googleUser;

  Future<UserCredential?> googlelogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      // If the user cancels the sign-in process, googleUser will be null.
      if (googleUser == null) {
        debugPrint('Google sign-in was cancelled by the user.');
        return null;
      }
      _googleUser = googleUser;

      final googleAuth = await googleUser.authentication;

      // Ensure we have the tokens before creating the credential
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('Google sign-in failed: Missing token.');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
      return userCredential;
    } catch (e) {
      
      debugPrint('AN ERROR OCCURRED DURING GOOGLE SIGN-IN: $e');
      return null;
    }
  }
  Future<void> logout() async {
  // This is the crucial part to sign out from Google
  await GoogleSignIn().signOut(); 
  
  // Then sign out from Firebase
  await FirebaseAuth.instance.signOut();
  
  notifyListeners();
}
}
