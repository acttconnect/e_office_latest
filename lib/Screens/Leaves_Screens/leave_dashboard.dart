import 'package:flutter/material.dart';
import 'approved_leaves.dart';
import 'pending_leaves.dart';
import 'rejected_leaves.dart';
import 'total_leaves_request.dart';

class LeaveDashboard extends StatelessWidget {
  final List<Map<String, String>> leaveRequests = [
    {
      'name': 'John Doe',
      'leaveType': 'Sick Leave',
      'startDate': '2024-08-20',
      'endDate': '2024-08-22',
      'status': 'Pending',
    },
    {
      'name': 'Jane Smith',
      'leaveType': 'Annual Leave',
      'startDate': '2024-08-15',
      'endDate': '2024-08-18',
      'status': 'Approved',
    },
    {
      'name': 'Alice Johnson',
      'leaveType': 'Casual Leave',
      'startDate': '2024-08-25',
      'endDate': '2024-08-26',
      'status': 'Pending',
    },
    {
      'name': 'Bob Brown',
      'leaveType': 'Sick Leave',
      'startDate': '2024-08-10',
      'endDate': '2024-08-12',
      'status': 'Rejected',
    }
  ];

  LeaveDashboard({Key? key}) : super(key: key);

  // Calculate leave statistics
  Map<String, int> get leaveStats {
    final totalLeaves = leaveRequests.length;
    final approved = leaveRequests.where((request) => request['status'] == 'Approved').length;
    final pending = leaveRequests.where((request) => request['status'] == 'Pending').length;
    final rejected = leaveRequests.where((request) => request['status'] == 'Rejected').length;

    return {
      'Approved': approved,
      'Pending': pending,
      'Rejected': rejected,
    };
  }


  @override
  Widget build(BuildContext context) {
    final leaveStats = this.leaveStats;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              context,
              title: 'Total Leave Requests',
              count: leaveRequests.length.toString(),
              color: Color(0xFF4769B2),
              icon: Icons.insert_chart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TotalLeaveRequests()),
              ),
            ),
            _buildSummaryCard(
              context,
              title: 'Pending Requests',
              count: leaveStats['Pending']?.toString() ?? '0',
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
              count: leaveStats['Approved']?.toString() ?? '0',
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
              count: leaveStats['Rejected']?.toString() ?? '0',
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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


// // Pie Chart
// Card(
//   elevation: 2,
//   color: Colors.white,
//   child: Container(
//     height: 200,
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: PieChart(
//         dataMap: leaveStats,
//         chartType: ChartType.ring,
//         colorList: [Colors.green, Color(0xFFfcb414), Colors.red],
//         legendOptions: LegendOptions(
//           showLegends: true,
//           legendPosition: LegendPosition.right,
//           legendTextStyle: TextStyle(fontSize: 16, color: Colors.black),
//         ),
//         chartValuesOptions: ChartValuesOptions(
//           showChartValuesInPercentage: true,
//           showChartValues: true,
//           showChartValuesOutside: true,
//           chartValueStyle: TextStyle(color: Colors.black),
//         ),
//       ),
//     ),
//   ),
// ),
// SizedBox(height: 16),
// // Linear Progress Indicator for remaining leaves
// Card(
//   elevation: 2,
//   color: Colors.white,
//   child: Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Remaining Leaves',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: 8),
//         LinearProgressIndicator(
//           value: remainingLeavePercentage,
//           backgroundColor: Colors.grey[300],
//           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4769B2)),
//         ),
//         SizedBox(height: 8),
//         Text(
//           '${remainingLeaves.toStringAsFixed(2)} of 10 days remaining',
//           style: TextStyle(fontSize: 16, color: Colors.black),
//         ),
//       ],
//     ),
//   ),
// ),
// SizedBox(height: 16),
// // GridView with fixed height
// GridView.count(
//   crossAxisCount: 2,
//   crossAxisSpacing: 8,
//   mainAxisSpacing: 8,
//   shrinkWrap: true,
//   physics: NeverScrollableScrollPhysics(), // Disable scrolling in GridView
//   childAspectRatio: 1.2,
//   children: [
//     InkWell(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => TotalLeaveRequests()));
//       },
//       child: Card(
//         color: Color(0xFF4769B2),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.insert_chart, size: 40, color: Colors.white),
//               SizedBox(height: 12),
//               Text(
//                 'Total Leave Requests',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 leaveRequests.length.toString(),
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     InkWell(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => PendingLeaves()));
//       },
//       child: Card(
//         color: Color(0xFFfcb414),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.hourglass_empty, size: 40, color: Colors.white),
//               SizedBox(height: 12),
//               Text(
//                 'Pending Requests',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 leaveRequests.where((request) => request['status'] == 'Pending').length.toString(),
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     InkWell(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovedLeaves()));
//       },
//       child: Card(
//         color: Colors.green,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.check_circle, size: 40, color: Colors.white),
//               SizedBox(height: 12),
//               Text(
//                 'Approved Requests',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 leaveRequests.where((request) => request['status'] == 'Approved').length.toString(),
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     InkWell(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => RejectedLeaves()));
//       },
//       child: Card(
//         color: Colors.red,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.cancel, size: 40, color: Colors.white),
//               SizedBox(height: 12),
//               Text(
//                 'Rejected Requests',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 leaveRequests.where((request) => request['status'] == 'Rejected').length.toString(),
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   ],
// ),