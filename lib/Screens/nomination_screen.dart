import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NominationForm extends StatefulWidget {
  @override
  _NominationFormState createState() => _NominationFormState();
}

class _NominationFormState extends State<NominationForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  TextEditingController _mainNomineeFullNameController =
      TextEditingController();
  TextEditingController _mainNomineePercentageController =
      TextEditingController(text: '100');
  TextEditingController _positionController = TextEditingController();
  TextEditingController _nominationFullNameController = TextEditingController();
  TextEditingController _nominationRelationshipController =
      TextEditingController();
  TextEditingController _atypicalEventsController = TextEditingController();
  TextEditingController _nominationAgeController = TextEditingController();
  TextEditingController _nominationBirthDateController =
      TextEditingController();
  TextEditingController _appointmentDateController = TextEditingController();

  // File paths for signatures
  String? _signatureMainUserPath;
  String? _signatureOfficeClerkPath;
  String? _signatureOfficeHeadPath;
  String? _signatureExtraVerificationPath;

  // List to hold sub-nominee controllers
  List<Map<String, TextEditingController>> _subNomineeControllers = [];
  double _totalPercentage = 0.0;

  // State, district, and taluka values
  String? _selectedState;
  String? _selectedDist;
  String? _selectedTaluka;
  String? _nominationType;

  // Tab controller
  late TabController _tabController;

  // Drop-down options
  final List<String> _states = ['State1', 'State2'];
  final List<String> _districts = ['Dist1', 'Dist2'];
  final List<String> _talukas = ['Taluka1', 'Taluka2'];
  final List<String> _nominationTypes = ['Main Nominee', 'Sub Nominee'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedState = prefs.getString('state') ?? 'No State Selected';
      _selectedDist = prefs.getString('district') ?? 'No District Selected';
      _selectedTaluka = prefs.getString('taluka') ?? 'No Taluka Selected';
    });
  }
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickImage(String field) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (field) {
          case 'mainUser':
            _signatureMainUserPath = pickedFile.path;
            break;
          case 'officeClerk':
            _signatureOfficeClerkPath = pickedFile.path;
            break;
          case 'officeHead':
            _signatureOfficeHeadPath = pickedFile.path;
            break;
          case 'extraVerification':
            _signatureExtraVerificationPath = pickedFile.path;
            break;
        }
      });
    }
  }

  void _addSubNomineeFields() {
    if (_nominationType == 'Sub Nominee') {
      setState(() {
        _subNomineeControllers.add({
          'name': TextEditingController(),
          'percentage': TextEditingController(),
        });
      });
    }else if(_nominationType == 'Main Nominee'){
      setState(() {
        _subNomineeControllers.add({
          'name': TextEditingController(),
          'percentage': TextEditingController(),
        });
      });
    }
  }

  void _removeSubNomineeFields(int index) {
    setState(() {
      _subNomineeControllers.removeAt(index);
      _totalPercentage = _subNomineeControllers.fold(
        0.0,
            (sum, pair) {
          final percentage = double.tryParse(pair['percentage']!.text) ?? 0.0;
          return sum + percentage;
        },
      );
    });
  }


  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_nominationType == 'Sub Nominee') {
        // Validate total percentage for sub-nominees
        double totalPercentage = 0.0;
        for (var controllerPair in _subNomineeControllers) {
          final percentage =
              double.tryParse(controllerPair['percentage']!.text) ?? 0.0;
          totalPercentage += percentage;
        }
        if (totalPercentage != 100) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Total percentage for sub-nominees must be exactly 100%')));
          return;
        }
      }

      // Handle form submission logic
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Processing Data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4769B2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text('Nomination Form',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        bottom: TabBar(
          indicatorPadding: EdgeInsets.all(8.0),
          indicatorColor: Colors.white,
          tabAlignment: TabAlignment.center,
          labelStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          unselectedLabelStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
          controller: _tabController,
          tabs: [
            Tab(text: 'User Details'),
            // Tab(text: 'Nominee Details'),
            Tab(text: 'Upload'),
          ],
        ),
      ),
      body: TabBarView(
        clipBehavior: Clip.none,
        // physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          // User Details Tab
          _buildUserDetailsTab(),
          // Nominee Details Tab
          // _buildNomineeDetailsTab(),
          // Signature Upload Tab
          _buildSignatureUploadTab(),
        ],
      ),
    );
  }

  Widget _buildUserDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // State Dropdown
              _buildDropdownField(
                value: _selectedState,
                items: _states,
                hint: 'Select State',
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // District Dropdown
              _buildDropdownField(
                value: _selectedDist,
                items: _districts,
                hint: 'Select District',
                onChanged: (value) {
                  setState(() {
                    _selectedDist = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Taluka Dropdown
              _buildDropdownField(
                value: _selectedTaluka,
                items: _talukas,
                hint: 'Select Taluka',
                onChanged: (value) {
                  setState(() {
                    _selectedTaluka = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Position Text Field
              _buildReadOnlyTextField(
                controller: _positionController,
                label: 'Position',
              ),
              SizedBox(height: 16.0),

              // Appointment Date Picker
              _buildDatePickerField(
                controller: _appointmentDateController,
                label: 'Appointment Date',
                onTap: () => _selectDate(_appointmentDateController),
              ),
              SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Nomination Full Name
                  TextFormField(
                    controller: _nominationFullNameController,
                    decoration: InputDecoration(
                      labelText: 'Nominee Full Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the nominee\'s full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),

                  // Nomination Birth Date Picker with Icon
                  TextFormField(
                    controller: _nominationBirthDateController,
                    decoration: InputDecoration(
                      labelText: 'Nominee Birth Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_nominationBirthDateController),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Nomination Relationship
                  TextFormField(
                    controller: _nominationRelationshipController,
                    decoration: InputDecoration(
                      labelText: 'Relationship to Main Nominee',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Nomination Age
                  TextFormField(
                    controller: _nominationAgeController,
                    decoration: InputDecoration(
                      labelText: 'Nominee Age',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the nominee\'s age';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),

                  // Nomination Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _nominationType,
                    items: _nominationTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    hint: Text('Select Nomination Type'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _nominationType = value;
                        // Clear sub-nominee fields if 'Main Nominee' is selected
                        if (_nominationType == 'Main Nominee') {
                          _subNomineeControllers.clear();
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16.0),

                  // Atypical Events - Only show for Main Nominee
                  if (_nominationType == 'Main Nominee') ...[
                    TextFormField(
                      controller: _atypicalEventsController,
                      decoration: InputDecoration(
                        labelText: 'Atypical Events',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Main Nominee Details
                    Text(
                      'Main Nominee Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _mainNomineeFullNameController,
                      decoration: InputDecoration(
                        labelText: 'Main Nominee Full Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the main nominee\'s full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _mainNomineePercentageController,
                      decoration: InputDecoration(
                        labelText: 'Main Nominee Percentage (%)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      readOnly: true,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        'Sub-Nominees',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Total Percentage: ${_totalPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _totalPercentage != 100 ? Colors.red : Colors.green,
                      ),
                    ),
                    ListView.builder(
                      itemCount: _subNomineeControllers.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final controllers = _subNomineeControllers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: controllers['name'],
                                  decoration: InputDecoration(
                                    labelText: 'Sub Nominee Name',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the sub-nominee\'s name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['percentage'],
                                  decoration: InputDecoration(
                                    labelText: 'Percentage (%)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _totalPercentage = _subNomineeControllers.fold(
                                        0.0,
                                            (sum, pair) {
                                          final percentage = double.tryParse(pair['percentage']!.text) ?? 0.0;
                                          return sum + percentage;
                                        },
                                      );
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () => _removeSubNomineeFields(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _totalPercentage >= 100 ? null : _addSubNomineeFields,
                      child: Text('Add Sub-Nominee', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        backgroundColor: Color(0xFF4769B2),
                      ),
                    ),
                  ],

                  // Add Sub-Nominee Fields - Only show for Sub Nominee
                  if (_nominationType == 'Sub Nominee') ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        'Sub-Nominees',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Total Percentage: ${_totalPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _totalPercentage != 100 ? Colors.red : Colors.green,
                      ),
                    ),
                    ListView.builder(
                      itemCount: _subNomineeControllers.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final controllers = _subNomineeControllers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: controllers['name'],
                                  decoration: InputDecoration(
                                    labelText: 'Sub Nominee Name',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the sub-nominee\'s name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['percentage'],
                                  decoration: InputDecoration(
                                    labelText: 'Percentage (%)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _totalPercentage = _subNomineeControllers.fold(
                                        0.0,
                                            (sum, pair) {
                                          final percentage = double.tryParse(pair['percentage']!.text) ?? 0.0;
                                          return sum + percentage;
                                        },
                                      );
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () => _removeSubNomineeFields(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _totalPercentage >= 100 ? null : _addSubNomineeFields,
                      child: Text('Add Sub-Nominee', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        backgroundColor: Color(0xFF4769B2),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      hint: Text(hint),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4769B2), width: 2.0),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        suffixIcon:
            Icon(Icons.lock, color: Colors.grey), // Indicating it's read-only
      ),
      readOnly: true,
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: onTap,
          tooltip: 'Select Date',
        ),
      ),
      readOnly: true,
    );
  }


  // Widget _buildNomineeDetailsTab() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: SingleChildScrollView(
  //       child:
  //     ),
  //   );
  // }




  Widget _buildSignatureUploadTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSignatureUploadCard(
                'D-Signature Main User', _signatureMainUserPath, 'mainUser'),
            SizedBox(height: 16.0),
            _buildSignatureUploadCard('D-Signature Office Clerk',
                _signatureOfficeClerkPath, 'officeClerk'),
            SizedBox(height: 16.0),
            _buildSignatureUploadCard('D-Signature Office Head',
                _signatureOfficeHeadPath, 'officeHead'),
            SizedBox(height: 16.0),
            _buildSignatureUploadCard('D-Signature Extra Verification',
                _signatureExtraVerificationPath, 'extraVerification'),
            SizedBox(height: 24.0),

            // Submit Button
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF4769B2),
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureUploadCard(
      String label, String? imagePath, String field) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shadowColor: Colors.grey,
      surfaceTintColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: imagePath != null
            ? Image.file(File(imagePath),
                width: double.infinity, height: 100, fit: BoxFit.cover)
            : Text('No file selected', style: TextStyle(color: Colors.grey)),
        trailing: IconButton(
          icon: Icon(Icons.upload_file),
          onPressed: () => _pickImage(field),
          tooltip: 'Upload Signature',
        ),
      ),
    );
  }
}
