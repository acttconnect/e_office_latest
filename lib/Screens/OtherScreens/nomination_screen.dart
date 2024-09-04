import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class NominationForm extends StatefulWidget {
  @override
  _NominationFormState createState() => _NominationFormState();
}

class _NominationFormState extends State<NominationForm>
    with SingleTickerProviderStateMixin {
  final List<FormData> _forms = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _personTypes = ['---', 'Main Nominee', 'Sub Nominee'];
  double _mainPersonTotalPercentage = 0.0;
  double _subPersonTotalPercentage = 0.0;
  List<String> nominationTypes = [];
  String? selectedNominationType;

  TabController? _tabController;

  // User data fields controllers
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _userBirthDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _addForm(); // Start with one form initially
    _tabController = TabController(length: 3, vsync: this);
    fetchNominationTypes();
  }

  Future<void> fetchNominationTypes() async {
    final response = await http.post(
        Uri.parse('https://e-office.acttconnect.com/api/get-nomination-type'));

    if (response.statusCode == 200|| response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        setState(() {
          nominationTypes = List<String>.from(
              jsonResponse['data'].map((item) => item['nomination_type']));
        });
      }
    } else {
      // Handle error
      print('Failed to load nomination types');
    }
  }

  // File paths for signatures
  String? _signatureMainUserPath;
  String? _signatureExtraVerificationPath1;
  String? _signatureExtraVerificationPath2;
  final ScrollController _scrollController = ScrollController();

  Future<void> pickImage(String field) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (field) {
          case 'mainUser':
            _signatureMainUserPath = pickedFile.path;
            break;
          case 'extraVerification1':
            _signatureExtraVerificationPath1 = pickedFile.path;
            break;
          case 'extraVerification2':
            _signatureExtraVerificationPath2 = pickedFile.path;
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers when the widget is removed
    for (var form in _forms) {
      form.dispose();
    }
    _tabController?.dispose();
    super.dispose();
    _positionController.dispose();
    _joiningDateController.dispose();
    _userBirthDateController.dispose();
  }

  void _addForm() {
    if (_mainPersonTotalPercentage == 100 && _subPersonTotalPercentage == 100) {
      _showErrorSnackbar(
          'Cannot add more forms. Total percentage for both Main and Sub Nominee has reached 100%.');
      return;
    }

    setState(() {
      _forms.add(FormData(
        nameController: TextEditingController(),
        birthDateController: TextEditingController(),
        relationController: TextEditingController(),
        ageController: TextEditingController(),
        percentageController: TextEditingController(),
        atypicalEventController: TextEditingController(),
        personType: '---',
      ));
    });
    // Scroll to the newly added form after the state has been updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _removeForm(int index) {
    setState(() {
      final removedForm = _forms.removeAt(index);
      _updateTotalPercentages();
      removedForm.dispose();
    });
  }

  void _updateTotalPercentages() {
    double mainPersonTotal = 0.0;
    double subPersonTotal = 0.0;

    for (var form in _forms) {
      final percentageText = form.percentageController.text;
      final percentage = double.tryParse(percentageText) ?? 0.0;

      if (form.personType == 'Main Nominee') {
        mainPersonTotal += percentage;
      } else if (form.personType == 'Sub Nominee') {
        subPersonTotal += percentage;
      }
    }

    setState(() {
      _mainPersonTotalPercentage = mainPersonTotal;
      _subPersonTotalPercentage = subPersonTotal;
    });
  }

  void _validateAndSaveForm(FormData form) {
    final percentageText = form.percentageController.text;
    final percentage = double.tryParse(percentageText) ?? 0.0;
    final personType = form.personType;

    if (personType == null) {
      return;
    }

    double currentTotal = personType == 'Main Nominee'
        ? _mainPersonTotalPercentage
        : _subPersonTotalPercentage;

    double newTotal =
        currentTotal - (form.previousPercentage ?? 0.0) + percentage;

    if (newTotal > 100) {
      _showErrorSnackbar(
          'Total percentage for $personType cannot exceed 100%.');
      form.percentageController.text =
          form.previousPercentage?.toString() ?? '';
    } else {
      setState(() {
        form.previousPercentage = percentage;
        _updateTotalPercentages();
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text = '${selectedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAddFormButton =
        _mainPersonTotalPercentage == 100 && _subPersonTotalPercentage == 100;

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
        backgroundColor: Color(0xFF4769B2),
        title: const Text('Nomination Form',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        bottom: TabBar(
          isScrollable: false,
          physics: NeverScrollableScrollPhysics(),
          indicatorColor: Colors.white,
          indicatorPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          unselectedLabelStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
          labelStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          controller: _tabController,
          tabs: [
            Tab(text: 'Nominee'),
            Tab(text: 'D-Signature'),
            Tab(text: 'Finalize'),
          ],
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          // Nominee Details Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _positionController,
                          decoration: InputDecoration(
                            labelText: 'Position',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _joiningDateController,
                          decoration: InputDecoration(
                            labelText: 'Joining Date',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12.0),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () =>
                                  _selectDate(_joiningDateController),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _userBirthDateController,
                          decoration: InputDecoration(
                            labelText: 'Birth Date',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12.0),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () =>
                                  _selectDate(_userBirthDateController),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey), // Set your desired border color
                            borderRadius: BorderRadius.circular(8.0), // Set the border radius
                          ),
                          child: nominationTypes.isNotEmpty
                              ? DropdownButton<String>(
                            hint: Text('Select Nomination Type'),
                            underline: SizedBox(), // Remove the default underline
                            padding:  EdgeInsets.symmetric(horizontal: 12.0),
                            isExpanded: true, // Make the dropdown take the full width
                            value: selectedNominationType,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedNominationType = newValue;
                              });
                            },
                            items: nominationTypes.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10), // Add some padding to the dropdown items
                                  child: Text(value),
                                ),
                              );
                            }).toList(),
                          )
                              : Center(child: CircularProgressIndicator()), // Center the loading indicator
                        ),
                      ),

                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        children: [
                          for (int i = 0; i < _forms.length; i++)
                            Builder(builder: (context) {
                              final form = _forms[i];
                              final isMainPerson =
                                  form.personType == 'Main Nominee';
                              return Card(
                                color: Colors.grey[50],
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 16.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Name Field
                                      TextFormField(
                                        controller: form.nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Nominee Full Name',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a name';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16.0),
                                      // Birth Date Field
                                      TextFormField(
                                        controller: form.birthDateController,
                                        decoration: InputDecoration(
                                          labelText: 'Nominee Birth Date',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.calendar_today),
                                            onPressed: () => _selectDate(
                                                form.birthDateController),
                                          ),
                                        ),
                                        readOnly: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a birth date';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16.0),
                                      // Relation Field
                                      TextFormField(
                                        controller: form.relationController,
                                        decoration: InputDecoration(
                                          labelText: 'Nominee Relation',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the relation';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16.0),
                                      // Age Field
                                      TextFormField(
                                        controller: form.ageController,
                                        decoration: InputDecoration(
                                          labelText: 'Nominee Age',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the age';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16.0),
                                      // Atypical Event Field (Only shown for Main Nominee)
                                      if (isMainPerson)
                                        TextFormField(
                                          controller:
                                              form.atypicalEventController,
                                          decoration: InputDecoration(
                                            labelText: 'Atypical Event',
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12.0),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an atypical event';
                                            }
                                            return null;
                                          },
                                        ),
                                      if (isMainPerson) SizedBox(height: 16.0),
                                      // Percentage Field
                                      TextFormField(
                                        controller: form.percentageController,
                                        decoration: InputDecoration(
                                          labelText: 'Nominee Percentage',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) =>
                                            _validateAndSaveForm(form),
                                      ),
                                      SizedBox(height: 16.0),
                                      // Person Type Dropdown
                                      DropdownButtonFormField<String>(
                                        value: form.personType,
                                        decoration: InputDecoration(
                                          labelText: 'Nominee Type',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                        ),
                                        items: _personTypes
                                            .map((type) =>
                                                DropdownMenuItem<String>(
                                                  value: type,
                                                  child: Text(type),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            form.personType = value;
                                            _updateTotalPercentages();
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a nominee type';
                                          }
                                          return null;
                                        },
                                      ),
                                      // New Nomination Type Dropdown
                                      SizedBox(height: 16.0),
                                      // Remove button for each form (only for forms beyond the first)
                                      if (i != 0)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _removeForm(i),
                                            tooltip: 'Remove Nominee',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            })
                        ],
                      ),
                    ],
                  ),
                ),
                // Add Form Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor:
                        disableAddFormButton ? Colors.grey : Color(0xFF4769B2),
                  ),
                  onPressed: disableAddFormButton ? null : _addForm,
                  child: Text('Add Nominee',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Upload Documents Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                // Upload Main User Signature
                _buildUploadSection(
                  'Upload Main Nominee Signature',
                  _signatureMainUserPath,
                  () => pickImage('mainUser'),
                ),
                SizedBox(height: 16.0),
                // Upload Extra Verification 1
                _buildUploadSection(
                  'Upload Witness Verification Signature 1',
                  _signatureExtraVerificationPath1,
                  () => pickImage('extraVerification1'),
                ),
                SizedBox(height: 16.0),
                // Upload Extra Verification 2
                _buildUploadSection(
                  'Upload Witness Verification Signature 2',
                  _signatureExtraVerificationPath2,
                  () => pickImage('extraVerification2'),
                ),

                //add next button here to go to the next tab
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: Color(0xFF4769B2),
                  ),
                  onPressed: () {
                    _tabController?.animateTo(2);
                  },
                  child: Text('Next', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Finalize Tab

          Image.asset(
            'assets/images/nf1.jpg',
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(
      String label, String? imagePath, VoidCallback onUpload) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: imagePath != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(imagePath),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextButton(
                    onPressed: onUpload,
                    child: Text('Change Image'),
                  ),
                ],
              )
            : ElevatedButton.icon(
                icon: Icon(
                  Icons.upload_file,
                  color: Colors.white,
                ),
                label: Text(
                  'Upload Signature',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4769B2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
      ),
    );
  }
}

class FormData {
  TextEditingController nameController;
  TextEditingController birthDateController;
  TextEditingController relationController;
  TextEditingController ageController;
  TextEditingController percentageController;
  TextEditingController atypicalEventController;
  String? personType;
  double? previousPercentage;

  FormData({
    required this.nameController,
    required this.birthDateController,
    required this.relationController,
    required this.ageController,
    required this.percentageController,
    required this.atypicalEventController,
    required this.personType,
  });

  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    relationController.dispose();
    ageController.dispose();
    percentageController.dispose();
    atypicalEventController.dispose();
  }
}
