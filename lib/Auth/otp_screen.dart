import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/main_screen.dart';
import '../api_services.dart'; // Import the ApiService
import 'package:intl/intl.dart';  // Import the intl package for date formatting


class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  OtpScreen({required this.phoneNumber, required this.otp});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = "";


  Future<void> verifyOtp() async {
    final result = await ApiService.verifyOtp(widget.phoneNumber, _otp);

    if (result['status'] == 'success') {
      final responseData = result['data'];
      if (responseData['msg'] == 'OTP verified successfully') {
        // Store the user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        // Format birth date if it exists
        String birthDateRaw = responseData['data']['birth_date'] ?? '';
        String formattedBirthDate = birthDateRaw.isNotEmpty
            ? DateFormat('MMMM d, yyyy').format(DateTime.parse(birthDateRaw))
            : '';

// Storing user data in SharedPreferences
        await prefs.setString('id', responseData['data']['id']?.toString() ?? '');
        print('User ID: ${responseData['data']['id']}');
        await prefs.setString('first_name', responseData['data']['first_name'] ?? '');
        await prefs.setString('last_name', responseData['data']['last_name'] ?? '');
        await prefs.setString('phone_number', responseData['data']['number'] ?? '');
        await prefs.setString('email', responseData['data']['email'] ?? '');
        await prefs.setBool('login_status', responseData['data']['login_status'] ?? false);
        await prefs.setString('is_admin', responseData['data']['is_admin'] ?? '');
        await prefs.setString('profile_pic', responseData['data']['profile_pic'] ?? '');
        await prefs.setString('joining_date', responseData['data']['joining_date'] ?? '');
        await prefs.setString('state', responseData['data']['state'] ?? '');
        await prefs.setString('district', responseData['data']['district'] ?? '');
        await prefs.setString('taluka', responseData['data']['taluka'] ?? '');
        await prefs.setInt('leaves', responseData['data']['leaves'] ?? 0);
        await prefs.setString('caste', responseData['data']['caste'] ?? '');
        await prefs.setString('address_B', responseData['data']['address_B'] ?? '');
        await prefs.setString('father_name', responseData['data']['father_name'] ?? '');
        await prefs.setString('father_address', responseData['data']['father_address'] ?? '');
        await prefs.setString('birth_date', formattedBirthDate);  // Save formatted birth date
        await prefs.setString('birth_text', responseData['data']['birth_text'] ?? '');
        await prefs.setString('birth_mark', responseData['data']['birth_mark'] ?? '');
        await prefs.setString('height', responseData['data']['height'] ?? '');
        await prefs.setString('qualification', responseData['data']['qualification'] ?? '');
        await prefs.setString('another_qualification', responseData['data']['another_qualification'] ?? '');
        await prefs.setString('digital_sig', responseData['data']['digital_sig'] ?? '');
        await prefs.setString('digital_sig_verify', responseData['data']['digital_sig_verify'] ?? '');
        await prefs.setString('certificate_no', responseData['data']['certificate_no'] ?? '');
        await prefs.setString('post_name', responseData['data']['post_name'] ?? '');
        await prefs.setString('created_at', responseData['data']['created_at'] ?? '');
        await prefs.setString('updated_at', responseData['data']['updated_at'] ?? '');

        print('User data saved to SharedPreferences');

        // Navigate to MainScreen after successful OTP verification
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        // Show error message if OTP is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Invalid OTP')),
        );
      }
    } else {
      // Show error if the API call failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 100,
                ),
                SizedBox(height: 24.0),
                const Text(
                  'Enter Verification Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'We have sent a verification code to ${widget.phoneNumber}. Please enter it below to verify.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    cursorColor: Colors.black,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: Color(0xFFfcb414),
                      inactiveColor: Colors.grey,
                      selectedColor: Color(0xFFfcb414),
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onCompleted: (value) {
                      setState(() {
                        _otp = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _otp = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      return true;
                    },
                  ),
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    backgroundColor: Color(0xFF4769B2),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    if (_otp.length == 6) {
                      verifyOtp();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid verification code')),
                      );
                    }
                  },
                  child: Text('Verify Code', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
