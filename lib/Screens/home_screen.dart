import 'package:e_office/Screens/Profile_Screens/userprofile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import the carousel slider package
import 'Leaves_Screens/leave_dashboard.dart';
import 'Salary_Screens/salary_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> statusUpdates = [
    {'status': 'Leave Request Approved', 'date': '2024-08-30', 'icon': Icons.check_circle, 'color': Colors.green},
    {'status': 'Salary Processed', 'date': '2024-08-29', 'icon': Icons.attach_money, 'color': Colors.amber},
    {'status': 'Leave Request Rejected', 'date': '2024-08-28', 'icon': Icons.cancel, 'color': Colors.red},
    // Add more status updates as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for consistency
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserProfileView()),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF4769B2), // Color consistent with the Leave Dashboard
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, John Doe',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Sat, 31 July 2024',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.bell, color: Colors.black87, size: 28),
                ],
              ),
            ),
            // Carousel Slider for Latest Statuses
            Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 100, // Height of the carousel items
                  autoPlay: true,
                  viewportFraction: 1.0, // Ensure items take full width
                  enlargeCenterPage: true, // Slightly enlarge the centered page
                ),
                items: statusUpdates.map((update) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Icon(
                            update['icon'],
                            size: 40,
                            color: Colors.black, // Changed icon color for visibility
                          ),
                          title: Text(
                            update['status'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Date: ${update['date']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          tileColor: Colors.white, // Uniform background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!), // Add a light border for definition
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Leave Dashboard',
                    color: Color(0xFF4769B2),
                    icon: Icons.calendar_today,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LeaveDashboard()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildGridItem(
                    context,
                    title: 'Salary Dashboard',
                    color: Color(0xFFfcb414),
                    icon: Icons.money,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SalaryDashboard()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context,
      {required String title,
        required Color color,
        required IconData icon,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 120,
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
