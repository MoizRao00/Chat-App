import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  //instance of auth and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? getCurrentUser(){
    return _auth.currentUser;

  }



  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      //sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info if it doesn't already exist
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid' : userCredential.user!.uid,
          "email" : email,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpEmailPassword(String email, password) async {
    try {
      //create service

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // save user info in a separate doc
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid' : userCredential.user!.uid,
          "email" : email,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  //errors
}
