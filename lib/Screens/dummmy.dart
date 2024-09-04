// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Models/receipt_by_status.dart';
// import '../api_services.dart';
//
// class ReceiptScreen extends StatefulWidget {
//   @override
//   _ReceiptScreenState createState() => _ReceiptScreenState();
// }
//
// class _ReceiptScreenState extends State<ReceiptScreen> {
//   Future<ReceiptByStatus>? _receiptData;
//   final ApiService _apiService = ApiService();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   Future<void> _fetchData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('id') ?? '0'; // Default to 0 if not found
//     setState(() {
//       _receiptData = _apiService.fetchReceiptsByStatus(int.parse(userId));
//     });
//   }
//
//   void _navigateToDetailScreen(String status, List<ReceiptTable> receipts) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReceiptDetailScreen(
//           status: status,
//           receipts: receipts,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Receipts by Status'),
//       ),
//       body: FutureBuilder<ReceiptByStatus>(
//         future: _receiptData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             ReceiptByStatus receiptData = snapshot.data!;
//             return Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => _navigateToDetailScreen(
//                           'Pending', receiptData.pendingReceipts),
//                       child: Text('Pending'),
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () => _navigateToDetailScreen(
//                           'Approved', receiptData.approvedReceipts),
//                       child: Text('Approved'),
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () => _navigateToDetailScreen(
//                           'Rejected', receiptData.rejectedReceipts),
//                       child: Text('Rejected'),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           }
//           return Container();
//         },
//       ),
//     );
//   }
// }
//
// class ReceiptDetailScreen extends StatelessWidget {
//   final String status;
//   final List<ReceiptTable> receipts;
//
//   ReceiptDetailScreen({
//     required this.status,
//     required this.receipts,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$status Receipts'),
//       ),
//       body: receipts.isNotEmpty
//           ? DataTable(
//         columns: [
//           DataColumn(label: Text('ID')),
//           DataColumn(label: Text('Subject')),
//           DataColumn(label: Text('Description')),
//           DataColumn(label: Text('Status')),
//           DataColumn(label: Text('PDF')),
//         ],
//         rows: receipts.map((receipt) {
//           return DataRow(cells: [
//             DataCell(Text(receipt.id.toString())),
//             DataCell(Text(receipt.subject)),
//             DataCell(Text(receipt.description)),
//             DataCell(Text(receipt.receiptStatus)),
//             DataCell(Text(receipt.receiptPdf)),
//           ]);
//         }).toList(),
//       )
//           : Center(child: Text('No receipts found')),
//     );
//   }
// }
