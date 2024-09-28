import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'approved_leaves.dart';
import 'pending_leaves.dart';
import 'rejected_leaves.dart';
import 'total_leaves_request.dart';

class LeaveDashboard extends StatefulWidget {
  const LeaveDashboard({Key? key}) : super(key: key);

  @override
  _LeaveDashboardState createState() => _LeaveDashboardState();
}

class _LeaveDashboardState extends State<LeaveDashboard> {
  int totalLeaves = 0;
  int approvedLeaves = 0;
  int pendingLeaves = 0;
  int rejectedLeaves = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaveCounts();
  }

  Future<void> fetchLeaveCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');

    if (userId != null) {
      final response = await http.post(
        Uri.parse(
            'https://e-office.acttconnect.com/api/get-leave-count?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200||response.statusCode == 201){
        final data = json.decode(response.body);
        if (data['success'] && data['data'].isNotEmpty) {
          // Accessing the leave data for the current month
          final leaveData = data['data'].values.first;

          setState(() {
            totalLeaves = leaveData['Total']; // Accessing Total leaves
            approvedLeaves = leaveData['Approved']; // Accessing Approved leaves
            pendingLeaves = leaveData['Pending']; // Accessing Pending leaves
            rejectedLeaves = leaveData['Rejected']; // Accessing Rejected leaves
            isLoading = false; // Stop loading on successful fetch
          });
        } else {
          // Handle the case where there is no leave data
          print('No leave data available.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Handle error
        print('Failed to fetch leave counts: ${response.statusCode} - ${response.body}');
        setState(() {
          isLoading = false; // Stop loading on error
        });
      }
    } else {
      // Handle user ID not found
      print('User ID not found in shared preferences');
      setState(() {
        isLoading = false; // Stop loading if user ID is not available
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4769B2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Leave Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              context,
              title: 'Total Leave Requests',
              count: totalLeaves.toString(),
              color: Color(0xFF4769B2),
              icon: Icons.insert_chart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TotalLeaveRequests()),
              ),
            ),
            _buildSummaryCard(
              context,
              title: 'Pending Requests',
              count: pendingLeaves.toString(),
              color: Color(0xFFfcb414),
              icon: Icons.hourglass_empty,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PendingLeaves()),
              ),
            ),
            _buildSummaryCard(
              context,
              title: 'Approved Requests',
              count: approvedLeaves.toString(),
              color: Colors.green,
              icon: Icons.check_circle,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApprovedLeaves()),
              ),
            ),
            _buildSummaryCard(
              context,
              title: 'Rejected Requests',
              count: rejectedLeaves.toString(),
              color: Colors.red,
              icon: Icons.cancel,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RejectedLeaves()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, {
        required String title,
        required String count,
        required Color color,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: color,
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 32),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          count,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
