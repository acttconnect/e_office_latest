import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Auth/login_screen.dart';
import 'editprofile_screen.dart';

class UserProfileView extends StatefulWidget {
  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  String firstName = '';
  String lastName = '';
  String contact = '';
  String address = '';
  String state = '';
  String joiningDate = '';
  String district = '';
  String taluka = '';
  String totalYearlyLeaves = '';
  String caste = '';
  String addressB = '';
  String fatherName = '';
  String fatherAddress = '';
  String birthDate = '';
  String birthText = '';
  String birthMark = '';
  String height = '';
  String qualification = '';
  String anotherQualification = '';
  String digitalSig = '';
  String digitalSigVerify = '';
  String certificateNo = '';
  String postName = '';
  String createdAt = '';
  String updatedAt = '';
  bool loginStatus = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
      contact = prefs.getString('number') ?? '';
      address = prefs.getString('address') ?? '';
      joiningDate = prefs.getString('joining_date') ?? '';
      state = prefs.getString('state') ?? '';
      district = prefs.getString('district') ?? '';
      taluka = prefs.getString('taluka') ?? '';
      totalYearlyLeaves = prefs.getInt('leaves')?.toString() ?? '0';
      caste = prefs.getString('caste') ?? '';
      addressB = prefs.getString('address_B') ?? '';
      fatherName = prefs.getString('father_name') ?? '';
      fatherAddress = prefs.getString('father_address') ?? '';
      birthDate = prefs.getString('birth_date') ?? 'Not Available';
      birthText = prefs.getString('birth_text') ?? '';
      birthMark = prefs.getString('birth_mark') ?? '';
      height = prefs.getString('height') ?? '';
      qualification = prefs.getString('qualification') ?? '';
      anotherQualification = prefs.getString('another_qualification') ?? '';
      digitalSig = prefs.getString('digital_sig') ?? '';
      digitalSigVerify = prefs.getString('digital_sig_verify') ?? '';
      certificateNo = prefs.getString('certificate_no') ?? '';
      postName = prefs.getString('post_name') ?? '';
      createdAt = prefs.getString('created_at') ?? '';
      updatedAt = prefs.getString('updated_at') ?? '';
      loginStatus = prefs.getBool('login_status') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Color(0xFF4769B2),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        child: ListView(
          children: <Widget>[
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Card(
                color: Colors.white,
                // elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                          image: DecorationImage(
                            image: AssetImage('assets/images/first.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$firstName $lastName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              contact,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear(); // Clear all preferences to log out
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => UserAppLoginScreen()),
                                (Route<dynamic> route) => false,
                          );
                        },
                        icon: Icon(Icons.logout, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Information Card
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // _buildSectionHeader('Personal Information'),
                    _buildProfileInfo('State', state),
                    _buildProfileInfo('District', district),
                    _buildProfileInfo('Taluka', taluka),
                    _buildProfileInfo('Full Name:', '$firstName $lastName'),
                    _buildProfileInfo('Email:', 'Not Available'),
                    _buildProfileInfo('Mobile:', contact),
                    _buildProfileInfo('Birth Date:', birthDate),
                    _buildProfileInfo('Birth Text:', birthText),
                    _buildProfileInfo('Location:', address),
                    _buildProfileInfo('Yearly Leaves:', totalYearlyLeaves),
                    // _buildSectionHeader('Additional Information'),

                    // _buildProfileInfo('Caste:', caste),
                    // _buildProfileInfo('Address B:', addressB),
                    // _buildProfileInfo('Father Name:', fatherName),
                    // _buildProfileInfo('Father Address:', fatherAddress),
                    // _buildProfileInfo('Birth Mark:', birthMark),
                    // _buildProfileInfo('Height:', height),
                    // _buildProfileInfo('Qualification:', qualification),
                    // _buildProfileInfo('Another Qualification:', anotherQualification),
                    // _buildProfileInfo('Digital Signature:', digitalSig),
                    // _buildProfileInfo('Digital Signature Verify:', digitalSigVerify),
                    // _buildProfileInfo('Certificate No:', certificateNo),
                    // _buildProfileInfo('Post Name:', postName),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileForm()),
                  );
                },
                child: Text('Edit Profile', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), backgroundColor: Color(0xFF4769B2),
                  textStyle: TextStyle(fontSize: 18),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4769B2),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
