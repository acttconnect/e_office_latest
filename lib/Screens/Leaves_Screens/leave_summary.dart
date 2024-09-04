import 'package:e_office/Screens/Leaves_Screens/apply_leaves.dart';
import 'package:e_office/Screens/Leaves_Screens/leave_dashboard.dart';
import 'package:e_office/Screens/Leaves_Screens/total_leaves_request.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaveSummaryScreen extends StatefulWidget {
  const LeaveSummaryScreen({Key? key}) : super(key: key);

  @override
  State<LeaveSummaryScreen> createState() => _LeaveSummaryScreenState();
}

class _LeaveSummaryScreenState extends State<LeaveSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final List<ChartSampleData> chartData = [
      ChartSampleData(x: 'June', approved: 10, pending: 15, rejected: 5),
      ChartSampleData(x: 'July', approved: 20, pending: 25, rejected: 10),
      ChartSampleData(x: 'August', approved: 30, pending: 35, rejected: 15),
      ChartSampleData(x: 'September', approved: 40, pending: 45, rejected: 20),
    ];

    // Calculate totals
    final totalApproved = chartData.map((data) => data.approved).reduce((a, b) => a + b);
    final totalPending = chartData.map((data) => data.pending).reduce((a, b) => a + b);
    final totalRejected = chartData.map((data) => data.rejected).reduce((a, b) => a + b);

    // Calculate percentages
    final total = totalApproved + totalPending + totalRejected;
    final double approvedPercentage = total > 0 ? totalApproved / total : 0;
    final double pendingPercentage = total > 0 ? totalPending / total : 0;
    final double rejectedPercentage = total > 0 ? totalRejected / total : 0;

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
      body: Padding(
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
                    barGroups: barChartGroups(chartData),
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
                            final index = value.toInt();
                            if (index >= 0 && index < chartData.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Center(
                                  child: Text(
                                    chartData[index].x,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            } else {
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
            icon: Icon(Icons.calendar_today,),
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
              MaterialPageRoute(builder: (context) =>  LeaveManagementForm()),
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

  List<BarChartGroupData> barChartGroups(List<ChartSampleData> chartData) {
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.approved.toDouble() + data.pending.toDouble() + data.rejected.toDouble(),
            color: Colors.red,
            width: 20,
            borderRadius: BorderRadius.zero,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: data.approved.toDouble() + data.pending.toDouble() + data.rejected.toDouble(),
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          BarChartRodData(
            toY: data.approved.toDouble() + data.pending.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.zero,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: data.approved.toDouble() + data.pending.toDouble(),
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          BarChartRodData(
            toY: data.approved.toDouble(),
            color: Colors.green,
            width: 20,
            borderRadius: BorderRadius.zero,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: data.approved.toDouble(),
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
      );
    }).toList();
  }
}

class ChartSampleData {
  ChartSampleData({required this.x, required this.approved, required this.pending, required this.rejected});

  final String x;
  final int approved;
  final int pending;
  final int rejected;
}
