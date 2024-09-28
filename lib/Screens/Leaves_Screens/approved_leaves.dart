import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class ApprovedLeaves extends StatefulWidget {
  const ApprovedLeaves({Key? key}) : super(key: key);

  @override
  State<ApprovedLeaves> createState() => _ApprovedLeavesState();
}

class _ApprovedLeavesState extends State<ApprovedLeaves> {
  List<Map<String, dynamic>> approvedLeaveRequests = [];
  List<bool> _selectedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApprovedLeaves();
  }

  Future<void> fetchApprovedLeaves() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');

    if (userId != null) {
      final response = await http.post(
        Uri.parse('https://e-office.acttconnect.com/api/get-user-leaves?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          approvedLeaveRequests = List<Map<String, dynamic>>.from(data['Total Approved Request']);
          _selectedItems = List.generate(approvedLeaveRequests.length, (index) => false);
        } else {
          print('Failed to fetch approved leave requests: ${data['message']}');
        }
      } else {
        print('Failed to fetch approved leave requests: ${response.statusCode}');
      }
    } else {
      print('User ID not found in shared preferences');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Toggle item selection
  void _toggleSelection(int index) {
    setState(() {
      _selectedItems[index] = !_selectedItems[index];
    });
  }

  void _downloadPdf() async {
    final pdf = pw.Document();
    List<Map<String, dynamic>> selectedRequests = [];

    // Collect selected leave requests
    for (int i = 0; i < approvedLeaveRequests.length; i++) {
      if (_selectedItems[i]) {
        selectedRequests.add(approvedLeaveRequests[i]);
      }
    }

    // Only create PDF if there are selected requests
    if (selectedRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No leave requests selected')),
      );
      return;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Approved Leave Requests', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Name', 'Leave Type', 'From', 'To', 'Status'],
                  ...selectedRequests.map((request) {
                    return [
                      request['subject']?.toString() ?? '',
                      request['leave_category']?.toString() ?? '',
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(request['start_date'])),
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(request['end_date'])),
                      request['status'].toString().capitalize(),
                    ];
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to the device
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/approved_leave_requests.pdf");
    await file.writeAsBytes(await pdf.save());

    // Provide feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF downloaded to: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = _selectedItems.contains(true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Approved Leaves', style: TextStyle(color: Colors.white, fontSize: 20)),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF4769B2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: approvedLeaveRequests.length,
                itemBuilder: (context, index) {
                  final request = approvedLeaveRequests[index];
                  return Card(
                    elevation: 2,
                    color: Colors.white,
                    child: ListTile(
                      leading: Checkbox(
                        value: _selectedItems[index],
                        onChanged: (bool? value) {
                          _toggleSelection(index);
                        },
                      ),
                      title: Text(
                        '${request['subject']} - ${request['leave_category']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'From: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(request['start_date']))}\n'
                            'To: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(request['end_date']))}',
                      ),
                      trailing: Text(
                        request['status'].toString().capitalize(),
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (anySelected)
              ElevatedButton(
                onPressed: _downloadPdf,
                child: Text('Download Selected', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4769B2), // Match the AppBar color
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return isNotEmpty ? this[0].toUpperCase() + substring(1).toLowerCase() : '';
  }
}
