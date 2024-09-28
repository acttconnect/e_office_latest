import 'package:e_office/Screens/Leaves_Screens/apply_leaves.dart';
import 'package:e_office/Screens/Leaves_Screens/leave_dashboard.dart';
import 'package:e_office/Screens/Leaves_Screens/total_leaves_request.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaveSummaryScreen extends StatefulWidget {
  const LeaveSummaryScreen({Key? key}) : super(key: key);

  @override
  State<LeaveSummaryScreen> createState() => _LeaveSummaryScreenState();
}

class _LeaveSummaryScreenState extends State<LeaveSummaryScreen> {
  double approvedPercentage = 0;
  double pendingPercentage = 0;
  double rejectedPercentage = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaveData();
  }

  Future<void> fetchLeaveData() async {
    final response = await http.post(Uri.parse('https://e-office.acttconnect.com/api/get-leave-count?user_id=42'));

    if (response.statusCode == 200||response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        final leaveData = data['data']['9-2024']; // Adjust this for the appropriate month key

        setState(() {
          approvedPercentage = leaveData['Approved_Percentage'] / 100;
          pendingPercentage = leaveData['Pending_Percentage'] / 100;
          rejectedPercentage = leaveData['Rejected_Percentage'] / 100;
          isLoading = false;
        });
      }
    } else {
      // Handle error
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        backgroundColor: const Color(0xFF4769B2),
        title: const Text('Leaves', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVAILABLE LEAVE\'S',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Text(
                  'JULY 2024 28 DAY\'S',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Circular Progress Indicators with Percentages and Labels Below
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularIndicator('Approved', Colors.green, approvedPercentage),
                Spacer(),
                _buildCircularIndicator('Pending', Colors.blue, pendingPercentage),
                Spacer(),
                _buildCircularIndicator('Rejected', Colors.red, rejectedPercentage),
              ],
            ),
            const SizedBox(height: 20),
            // Bar Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                child: BarChart(
                  BarChartData(
                    barGroups: barChartGroups(), // Pass the month names and data here
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            // Show the month name on the x-axis
                            switch (value.toInt()) {
                              case 0:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text('Sep', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                              case 1:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text('Oct', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                            // Add more cases for additional months if needed
                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toString(),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4769B2),
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        unselectedLabelStyle: const TextStyle(color: Colors.black, fontSize: 12),
        selectedLabelStyle: const TextStyle(color: Color(0xFF4769B2), fontSize: 14),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Date',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_arrow_down),
            label: 'Apply',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All List',
          ),
        ],
        onTap: (index) async {
          if (index == 0) {
            // Show date range picker when "Date" is selected
            final DateTimeRange? pickedDateRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );

            if (pickedDateRange != null) {
              final fromDate = pickedDateRange.start;
              final toDate = pickedDateRange.end;

              // Show a snackbar or dialog to notify users about the selected date range
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected Date Range: From ${fromDate.toLocal().toString().split(' ')[0]} To ${toDate.toLocal().toString().split(' ')[0]}'),
                ),
              );
            }
          } else if (index == 1) {
            // Navigate to Leave Dashboard when "Apply" is selected
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeaveManagementForm()),
            );
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TotalLeaveRequests()));
          } else if (index == 3) {
            // Navigate to Leave Dashboard when "All List" is selected
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeaveDashboard()),
            );
          }
        },
      ),
    );
  }

  Widget _buildCircularIndicator(String title, Color color, double percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                color: color,
                strokeWidth: 8,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  List<BarChartGroupData> barChartGroups() {
    // Return a single group of data for the current month
    return [
      BarChartGroupData(
        x: 0, // September
        barRods: [
          BarChartRodData(
            toY: approvedPercentage * 100, // Approved percentage
            color: Colors.green,
            width: 20,
          ),
          BarChartRodData(
            toY: pendingPercentage * 100, // Pending percentage
            color: Colors.blue,
            width: 20,
          ),
          BarChartRodData(
            toY: rejectedPercentage * 100, // Rejected percentage
            color: Colors.red,
            width: 20,
          ),
        ],
      ),
    ];
  }
}
