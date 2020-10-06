import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhoneSigin {
  //phone authentication
  signInWithPhone(String phone, BuildContext context, String deviceToken) async {
    CircularProgressIndicator();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    Firestore firestore = Firestore.instance;
    final phoneNumberController = new TextEditingController();
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 30),
        verificationCompleted: (AuthCredential authCredential) async {
          FirebaseUser firebaseUser =
              (await firebaseAuth.signInWithCredential(authCredential)).user;
          CircularProgressIndicator();
          if (firebaseUser != null) {
            final QuerySnapshot result = await Firestore.instance
                .collection("users")
                .where("id", isEqualTo: firebaseUser.uid)
                .getDocuments();
            final List<DocumentSnapshot> documents = result.documents;

            if (documents.length == 0) {
              //adding user to the table or relation
              firestore.collection("users").document(firebaseUser.uid).setData({
                "id": firebaseUser.uid,
                "deviceToken": deviceToken.toString(),
              });
            }
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) => Demo()));
          } else {
            print("Login Failed");
          }
          //actual process ends
        },
        verificationFailed: (AuthException exception) {
          return exception.toString();
        },
        codeSent: (String verificationId, [int forceResendToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text('Your OTP'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                            hintText: 'Please Enter OTP',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    actions: [
                      FlatButton(
                          color: Colors.white,
                          onPressed: () async {
                            var credentials = PhoneAuthProvider.getCredential(
                                verificationId: verificationId,
                                smsCode: phoneNumberController.text.trim());
                            // actual process starts
                            FirebaseUser firebaseUser = (await firebaseAuth
                                    .signInWithCredential(credentials))
                                .user;
                            CircularProgressIndicator();
                            if (firebaseUser != null) {
                              final QuerySnapshot result = await Firestore
                                  .instance
                                  .collection("users")
                                  .where("id", isEqualTo: firebaseUser.uid)
                                  .getDocuments();
                              final List<DocumentSnapshot> documents =
                                  result.documents;

                              if (documents.length == 0) {
                                //adding user to the table or relation
                                firestore
                                    .collection("users")
                                    .document(firebaseUser.uid)
                                    .setData({
                                  "id": firebaseUser.uid,
                                  "deviceToken": deviceToken.toString(),
                                });
                              }
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Demo()));
                            } else {
                              print("Login Failed");
                            }
                            //actual process ends
                          },
                          child: Text('Submit',
                              style: TextStyle(color: Colors.red)))
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout");
        });
  }

  //return the current user
  Future<FirebaseUser> getUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser();
  }
}
