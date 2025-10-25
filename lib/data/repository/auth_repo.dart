import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stichanda_driver/data/models/profile_model.dart';
import 'package:stichanda_driver/helper/firebase_error_handler.dart';
// all firebase logic here

class AuthRepo{

  final _instance=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;

  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user=await _firestore.collection('driver').doc(userCredential.user!.uid).get();
      if(!user.exists){
        await _instance.signOut();
        return AuthResult(
          success: false,
          message: 'No driver profile found for this user',
        );
      }
      return AuthResult(
        success: true,
        message: 'Sign-in successful',
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: FirebaseErrorHandler.getErrorMessage(e, context: 'signInWithEmailAndPassword'),
      );
    }
  }

  Future<AuthResult> signUpWithEmailAndPassword(String email, String password,String fname,String lname,String phone) async {
    try {
      UserCredential userCredential = await _instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid=userCredential.user!.uid;
      await _firestore.collection('driver').doc(uid).set({
        'driver_id': uid,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'name':'$fname $lname',
        'availiability_status':0, //0->offline , 1->online
        'cnic_image_path':'',// after uploading cnic image to supabase
        'current_location':{
          'longitude':0.0,
          'latitude':0.0
        },
        'is_assigned':0,
        'phone':phone,
        'verification_status':0 // 0->pending, 1->verified, 2->rejected

      });
      return AuthResult(
        success: true,
        message: 'Sign-up successful',
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: FirebaseErrorHandler.getErrorMessage(e, context: 'signUpWithEmailAndPassword'),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'sendPasswordResetEmail');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _instance.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'updatePassword');
    }
  }

  Future<void> updateCurrentLocation(double latitude,double longitude) async {
    String uid=_instance.currentUser!.uid;
    return _firestore.collection('driver').doc(uid).update({
      'current_location':{
        'latitude':latitude,
        'longitude':longitude
      },
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    await _instance.signOut();
  }

  Future<ProfileModel?> getDriverProfile() async {
    String uid=_instance.currentUser!.uid;
    DocumentSnapshot docSnapshot=await _firestore.collection('driver').doc(uid).get();
    if(docSnapshot.exists){
      return ProfileModel.fromJson(docSnapshot.data() as Map<String,dynamic>);
    }
    return null;
  }

  Future<ProfileModel?> updateDriverProfile(Map<String,dynamic> updatedData) async {
    String uid=_instance.currentUser!.uid;
    await _firestore.collection('driver').doc(uid).update(updatedData);
    DocumentSnapshot docSnapshot=await _firestore.collection('driver').doc(uid).get();
    if(docSnapshot.exists){
      return ProfileModel.fromJson(docSnapshot.data() as Map<String,dynamic>);
    }
    return null;
  }

  Stream<ProfileModel?> driverProfileStream(String uid){
    return _firestore.collection('driver').doc(uid).snapshots().map((snapshot){
      if(!snapshot.exists) return null;
      return ProfileModel.fromJson(snapshot.data() as Map<String,dynamic>);
    });
  }

  Future<bool> updateActiveStatus(int status){
    String uid=_instance.currentUser!.uid;
    return _firestore.collection('driver').doc(uid).update({
      'availiability_status':status,
      'updated_at': FieldValue.serverTimestamp(),
    }).then((value) => true).catchError((error){
      return false;
    });

  }


}

class AuthResult {
  final bool success;
  final String message;
  final User? user; // FirebaseAuth User (optional)

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
