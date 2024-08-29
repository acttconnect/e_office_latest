import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_services.dart';

class LeaveManagementForm extends StatefulWidget {
  @override
  _LeaveManagementFormState createState() => _LeaveManagementFormState();
}

class _LeaveManagementFormState extends State<LeaveManagementForm> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  String? _selectedState;
  String? _selectedDist;
  String? _selectedTaluka;
  DateTime _leaveStartDate = DateTime.now();
  DateTime _leaveEndDate = DateTime.now();
  DateTime _leaveAppliedStartDate = DateTime.now();
  DateTime _leaveAppliedEndDate = DateTime.now();
  String? _leaveSubject;
  String? _leaveDescription;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedState = prefs.getString('state') ?? 'No State Selected';
      _selectedDist = prefs.getString('district') ?? 'No District Selected';
      _selectedTaluka = prefs.getString('taluka') ?? 'No Taluka Selected';
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  Widget _buildDateField(String label, DateTime selectedDate, Function(DateTime) onDateChanged) {
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(selectedDate),
    );

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      controller: dateController,
      onTap: () async {
        await _selectDate(context, selectedDate, (date) {
          setState(() {
            onDateChanged(date);
          });
          dateController.text = DateFormat('yyyy-MM-dd').format(date);
        });
      },
    );
  }

  Widget _buildStaticField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Create an instance of ApiService
      final apiService = ApiService();

      // Submit the leave request
      try {
        await apiService.submitLeaveRequest(
          state: _selectedState ?? 'No State Selected',
          district: _selectedDist ?? 'No District Selected',
          taluka: _selectedTaluka ?? 'No Taluka Selected',
          leaveStartDate: _leaveStartDate,
          leaveEndDate: _leaveEndDate,
          leaveAppliedStartDate: _leaveAppliedStartDate,
          leaveAppliedEndDate: _leaveAppliedEndDate,
          leaveSubject: _leaveSubject ?? '',
          leaveDescription: _leaveDescription ?? '',
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave applied successfully')),
        );

        // Navigate back to the main screen
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });

      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to apply leave')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4769B2),
        title: Text('Leave Management', style: TextStyle(color: Colors.white, fontSize: 20)),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16),

                      // Static State Display
                      _buildStaticField('State', _selectedState ?? 'No State Selected'),
                      SizedBox(height: 16),

                      // Static District Display
                      _buildStaticField('District', _selectedDist ?? 'No District Selected'),
                      SizedBox(height: 16),

                      // Static Taluka Display
                      _buildStaticField('Taluka', _selectedTaluka ?? 'No Taluka Selected'),
                      SizedBox(height: 16),

                      // Leave Starting Date
                      _buildDateField(
                        'Leave Starting Date',
                        _leaveStartDate,
                            (date) {
                          setState(() {
                            _leaveStartDate = date;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Leave Ending Date
                      _buildDateField(
                        'Leave Ending Date',
                        _leaveEndDate,
                            (date) {
                          setState(() {
                            _leaveEndDate = date;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Leave Applied Starting Date
                      _buildDateField(
                        'Leave Applied Starting Date',
                        _leaveAppliedStartDate,
                            (date) {
                          setState(() {
                            _leaveAppliedStartDate = date;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Leave Applied Ending Date
                      _buildDateField(
                        'Leave Applied Ending Date',
                        _leaveAppliedEndDate,
                            (date) {
                          setState(() {
                            _leaveAppliedEndDate = date;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Leave Subject
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Leave Subject',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _leaveSubject = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Leave Description
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Leave Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4, // Makes the text field larger for multi-line input
                        onChanged: (value) {
                          setState(() {
                            _leaveDescription = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: TextStyle(fontSize: 18),
                minimumSize: Size(double.infinity, 40),
                backgroundColor: Color(0xFF4769B2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
