import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApprovedLeaves extends StatefulWidget {
  const ApprovedLeaves({super.key});

  @override
  State<ApprovedLeaves> createState() => _ApprovedLeavesState();
}

class _ApprovedLeavesState extends State<ApprovedLeaves> {
  final List<Map<String, String>> leaveRequests = [
    {
      'name': 'John Doe',
      'leaveType': 'Sick Leave',
      'startDate': '2024-08-20',
      'endDate': '2024-08-22',
      'status': 'Approved',
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
      'status': 'Approved',
    },
    {
      'name': 'Bob Brown',
      'leaveType': 'Sick Leave',
      'startDate': '2024-08-10',
      'endDate': '2024-08-12',
      'status': 'Approved',
    }
  ];

  // Track selected items
  List<bool> _selectedItems = List.generate(4, (index) => false);

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Leave Requests List
            Expanded(
              child: ListView.builder(
                itemCount: leaveRequests.length,
                itemBuilder: (context, index) {
                  final request = leaveRequests[index];
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
                        '${request['name']} - ${request['leaveType']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'From: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(request['startDate']!))}\n'
                            'To: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(request['endDate']!))}',
                      ),
                      trailing: Text(
                        request['status']!,
                        style: TextStyle(
                          color: request['status'] == 'Approved' ? Colors.green : Colors.red,
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
                onPressed: () {
                  // Implement download functionality here
                },
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
