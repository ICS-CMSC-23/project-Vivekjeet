import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Stream<User?> getUser() {
    return auth.authStateChanges();
  }

  Future<List<String>> uploadProofs(UserCredential credential, List<File> proofs) async {
    List<String> urls = [];
    for (int i = 0; i < proofs.length; i++) {
      try {
        String imagePath = "proofs/${credential.user!.email}/images$i";
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child(imagePath).putFile(proofs[i]);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        urls.add(downloadUrl);
      } catch (e) {
        print('Error uploading proof $i: $e');
      }
    }
    return urls;
  }

  Future<void> signUp(
    Map<String, dynamic> details, String email, String password, List<File> proofs) async {
    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await db.collection("users")
        .doc(credential.user!.uid)
        .set(details);
      await db.collection("users")
        .doc(credential.user!.uid)
        .update({'userId': credential.user!.uid});

      if(proofs.isNotEmpty){
        List<String> urls = await uploadProofs(credential, proofs);
      
        await db.collection("users")
          .doc(credential.user!.uid)
          .update({'proofs': urls});
      }
      
    } on FirebaseAuthException catch (e) {
      //possible to return something more useful
      //than just print an error message to improve UI/UX
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    UserCredential credential;
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      //let's print the object returned by signInWithEmailAndPassword
      //you can use this object to get the user's id, email, etc.
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //possible to return something more useful
        //than just print an error message to improve UI/UX
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      throw (e);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await auth.signInWithCredential(credential);
      return userCredential;
    }
    throw FirebaseAuthException(
      code: 'ERROR_ABORTED_BY_USER',
      message: 'Sign in aborted by user.',
    );
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();  // Sign out from Google
    await auth.signOut();          // Sign out from Firebase
  }
}