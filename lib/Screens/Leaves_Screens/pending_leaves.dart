import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PendingLeaves extends StatefulWidget {
  const PendingLeaves({super.key});

  @override
  State<PendingLeaves> createState() => _PendingLeavesState();
}

class _PendingLeavesState extends State<PendingLeaves> {
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
      'status': 'Pending',
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
      'status': 'Pending',
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
        onPressed: () {
          // Add your download logic here
        },
        child: Icon(Icons.download, color: Colors.white),
        backgroundColor: Color(0xFF4769B2),
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
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
                          color: request['status'] == 'Pending' ? Colors.yellow : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
