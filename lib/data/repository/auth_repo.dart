import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// all firebase logic here

class AuthRepo{

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password,String fname,String lname,String phone) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid=userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('driver').doc(uid).set({
        'driver_id': uid,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'name':'$fname $lname',
        'aviliability_status':0, //0->offline , 1->online
        'cnic_image_path':'',// after uploading cnic image to supabase
        'current_location':{
          'longitude':0.0,
          'latitude':0.0
        },
        'is_verified':false,
        'phone':phone,
        'verification_status':0 // 0->pending, 1->verified, 2->rejected

      });
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }


  Future<bool> updateActiveStatus(){
    //write here logic to update status in firebase
    //dummy implementation
    return Future.value(true);
  }


}