import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class PendingLeaves extends StatefulWidget {
  const PendingLeaves({Key? key}) : super(key: key);

  @override
  State<PendingLeaves> createState() => _PendingLeavesState();
}

class _PendingLeavesState extends State<PendingLeaves> {
  List<Map<String, dynamic>> pendingLeaveRequests = [];
  List<bool> _selectedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingLeaves();
  }

  Future<void> fetchPendingLeaves() async {
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
          pendingLeaveRequests = List<Map<String, dynamic>>.from(data['Total Pending Request']);
          _selectedItems = List.generate(pendingLeaveRequests.length, (index) => false);
        } else {
          print('Failed to fetch pending leave requests: ${data['message']}');
        }
      } else {
        print('Failed to fetch pending leave requests: ${response.statusCode}');
      }
    } else {
      print('User ID not found in shared preferences');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _downloadPdf() async {
    final pdf = pw.Document();
    List<Map<String, dynamic>> selectedRequests = [];

    // Collect selected leave requests
    for (int i = 0; i < pendingLeaveRequests.length; i++) {
      if (_selectedItems[i]) {
        selectedRequests.add(pendingLeaveRequests[i]);
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
              pw.Text('Pending Leave Requests', style: pw.TextStyle(fontSize: 24)),
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
    final file = File("${output.path}/pending_leave_requests.pdf");
    await file.writeAsBytes(await pdf.save());

    // Provide feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF downloaded to: ${file.path}')),
    );
  }

  // Toggle item selection
  void _toggleSelection(int index) {
    setState(() {
      _selectedItems[index] = !_selectedItems[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = _selectedItems.contains(true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pending Leaves', style: TextStyle(color: Colors.white, fontSize: 20)),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF4769B2),
      ),
      floatingActionButton: anySelected
          ? FloatingActionButton(
        onPressed: _downloadPdf,
        child: Icon(Icons.download, color: Colors.white),
        backgroundColor: Color(0xFF4769B2),
      )
          : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView.builder(
          itemCount: pendingLeaveRequests.length,
          itemBuilder: (context, index) {
            final request = pendingLeaveRequests[index];
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
                    color: Colors.yellow, // Yellow for pending status
                  ),
                ),
              ),
            );
          },
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
