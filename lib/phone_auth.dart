import 'backend.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

String phone, token;
FirebaseMessaging fcm = new FirebaseMessaging();

class PhoneAuthentication extends StatefulWidget {
  @override
  _PhoneAuthenticationState createState() => _PhoneAuthenticationState();
}

class _PhoneAuthenticationState extends State<PhoneAuthentication> {

  PhoneSigin phoneSigin = new PhoneSigin();

  getToken() async {
    setState(() async {
       token = await fcm.getToken();
      //print("FirebaseMessaging token: $token");
    });
  }

  @override
  void initState() {
    super.initState();
    getToken();
    phoneSigin.getUser().then((user) {
      if (user != null)
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Demo()));
    });
  }

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      phone = internationalizedPhoneNumber;
    });
    //print(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Authentication'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: InternationalPhoneInput(
              decoration: InputDecoration.collapsed(
                  hintText: 'Enter Phone Number',
                  hintStyle: TextStyle(color: Colors.grey)),
              onPhoneNumberChange: onPhoneNumberChange,
              initialPhoneNumber: phone,
              showCountryCodes: true,
              showCountryFlags: true,
            ),
          ),
          Builder(
            builder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                    child:
                        Text('Continue', style: TextStyle(color: Colors.white)),
                    color: Colors.red,
                    onPressed: () {
                      if (phone.length == 0) {
                        print(token);
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Invalid Phone Number'),
                          duration: Duration(seconds: 3),
                        ));
                      } else {
                        phoneSigin.signInWithPhone(phone.toString(), context,token);
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
