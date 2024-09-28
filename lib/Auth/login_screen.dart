import 'package:e_office/Auth/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services.dart'; // Ensure the correct path to your ApiService

class UserAppLoginScreen extends StatefulWidget {
  const UserAppLoginScreen({super.key});

  @override
  _UserAppLoginScreenState createState() => _UserAppLoginScreenState();
}

class _UserAppLoginScreenState extends State<UserAppLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = ''; // Reset error message
      });

      final mobileNumber = _mobileController.text.trim();
      try {
        // Call the API to get OTP and the message
        final response = await ApiService.login(mobileNumber);

        // Debugging the response
        print('API Response: $response');

        // Check if the response contains the 'otp' field
        if (response['otp'] is int) {
          // Convert the OTP to a String
          final otp = response['otp'].toString();

          print('Login successful, OTP: $otp');

          // Save login status to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);

          // Navigate to OtpScreen with the OTP
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: mobileNumber, otp: otp)),
          );
        } else {
          // Handle the case where 'otp' is not an int
          throw Exception('Unexpected response format: OTP is not an int');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.jpg', // Ensure this asset path is correct
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 24.0),
                  const Text(
                    'Welcome to eOffice',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Sign in or sign up to create & manage documents in the workflow',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 30.0),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _mobileController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),

                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),

                  SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      backgroundColor: Color(0xFF4769B2),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }
}
