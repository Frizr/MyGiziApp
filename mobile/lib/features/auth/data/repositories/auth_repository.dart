import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream status login user saat ini
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(String name, String email, String password) async {
    // 1. Daftarkan auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Set display name di Firebase Auth
    await userCredential.user?.updateDisplayName(name);

    // 3. Simpan data profil ke Firestore (Untuk Leaderboard nanti)
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'score': 0, // Skor default awal gamifikasi
        'level': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
