import 'package:e_office/Screens/Profile_Screens/userprofile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Import this for SharedPreferences

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({super.key});

  @override
  _UserProfileFormState createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalYearlyLeavesController = TextEditingController();
  final _linkController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _talukaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _contactController.text = prefs.getString('number') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _totalYearlyLeavesController.text = (prefs.getInt('leaves')?.toString() ?? '0');
      _linkController.text = prefs.getString('drive_link') ?? '';
      _stateController.text = prefs.getString('state') ?? '';
      _districtController.text = prefs.getString('district') ?? '';
      _talukaController.text = prefs.getString('taluka') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(color: Colors.white, fontSize: 20)),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF4769B2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Display Form Fields with saved data
              _buildReadOnlyTextFormField(_stateController, 'State'),
              const SizedBox(height: 16),
              _buildReadOnlyTextFormField(_districtController, 'District'),
              const SizedBox(height: 16),
              _buildReadOnlyTextFormField(_talukaController, 'Taluka'),
              const SizedBox(height: 16),
              _buildTextFormField(_firstNameController, 'First Name'),
              const SizedBox(height: 16),
              _buildTextFormField(_lastNameController, 'Last Name'),
              const SizedBox(height: 16),
              _buildTextFormField(_contactController, 'Contact', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextFormField(_addressController, 'Address'),
              const SizedBox(height: 16),
              _buildTextFormField(_totalYearlyLeavesController, 'Total Yearly Leaves', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextFormField(_linkController, 'Drive Link'),
              const SizedBox(height: 20),
              // Edit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfileView()), // Replace with your actual profile view widget
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    textStyle: TextStyle(fontSize: 18),
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: Color(0xFF4769B2),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextFormField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],  // Light grey background for read-only fields
      ),
      readOnly: true,
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}
