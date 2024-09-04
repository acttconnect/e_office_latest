import 'package:e_office/Models/receipt_model.dart';
import 'package:e_office/Screens/Profile_Screens/userprofile_screen.dart';
import 'package:e_office/Screens/receipt_table.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/receipt_by_status.dart';
import '../api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> isSelected = [true, false, false];
  int selectedIndex = 0;
  String firstName = '';
  String lastName = '';
  String _formattedDate = '';

  GetReceiptResponse? getReceiptResponse;
  late bool loading;
  String? error;

  Future getReceiptData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id');
      ApiService apiServices = ApiService();
      getReceiptResponse = await apiServices.getReceipt(userId!);
    } catch (e) {
      error = e.toString();
    }
  }

  void initialize() async {
    setState(() {
      loading = true;
    });
    await getReceiptData();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loading = false;
    initialize();
    _loadUserData();
    _setDate();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
    });
  }

  void updateData(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
      selectedIndex = index;
    });
  }

  Widget getSelectedWidget() {
    switch (selectedIndex) {
      case 0:
        return Widget1(); // First widget
      case 1:
        return Widget2(); // Second widget
      case 2:
        return Widget3(
          receipts: getReceiptResponse?.receipt ?? [],
        ); // Third widget
      default:
        return Widget1(); // Default to Widget1
    }
  }

  final List<Map<String, dynamic>> statusUpdates = [
    {
      'status': 'Leave Request Approved',
      'date': '2024-08-30',
      'image': 'assets/images/mark.jpg', // Store path as string
    },
    {
      'status': 'Salary Processed',
      'date': '2024-08-29',
      'image': 'assets/images/salary.jpg', // Store path as string
    },
    {
      'status': 'Leave Request Rejected',
      'date': '2024-08-28',
      'image': 'assets/images/rejected.jpg', // Store path as string
    },
    // Add more status updates as needed
  ];

  void _setDate() {
    // Get the current date
    DateTime now = DateTime.now();

    // Format the day to show only the first three letters (Mon, Tue, etc.)
    String day = DateFormat('E').format(now);

    // Format the date as per your need (e.g., 21-Sep-2024)
    String date = DateFormat('dd MMM yyyy').format(now);

    // Set the formatted date
    setState(() {
      _formattedDate = '$day, $date';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfileView()),
                      );
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF4769B2),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $firstName $lastName',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _formattedDate,
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
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/notification');
                      },
                      icon: Icon(Icons.notifications_none_outlined)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Carousel Slider for Latest Statuses
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Image.asset(
                            update['image'], // Use image path as string
                            width: 40,
                            height: 40,
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
                          tileColor: Colors.white,
                          // Uniform background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.grey[
                                    300]! // Add a light border for definition
                                ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10), // Add some spacing at the top
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: selectedIndex == index
                                ? Colors.white
                                : Colors.black,
                            backgroundColor: selectedIndex == index
                                ? Color(0xFF4769B2)
                                : Colors.grey[300],
                            // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(30, 40), // Adjust width as needed
                          ),
                          onPressed: () => updateData(index),
                          child: Text(
                            index == 0
                                ? 'Leaves'
                                : index == 1
                                    ? 'Salary'
                                    : 'Receipt',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 10), // Spacing between buttons and content
                  Expanded(
                    child: getSelectedWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget 1 - Includes circular indicators and a bar chart
class Widget1 extends StatelessWidget {
  final List<ChartSampleData> chartData = [
    ChartSampleData(x: 'June', approved: 10, pending: 15, rejected: 5),
    ChartSampleData(x: 'July', approved: 20, pending: 25, rejected: 10),
    ChartSampleData(x: 'August', approved: 30, pending: 35, rejected: 15),
    ChartSampleData(x: 'September', approved: 40, pending: 45, rejected: 20),
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    final totalApproved =
        chartData.map((data) => data.approved).reduce((a, b) => a + b);
    final totalPending =
        chartData.map((data) => data.pending).reduce((a, b) => a + b);
    final totalRejected =
        chartData.map((data) => data.rejected).reduce((a, b) => a + b);

    // Calculate percentages
    final total = totalApproved + totalPending + totalRejected;
    final double approvedPercentage = total > 0 ? totalApproved / total : 0;
    final double pendingPercentage = total > 0 ? totalPending / total : 0;
    final double rejectedPercentage = total > 0 ? totalRejected / total : 0;

    return Column(
      children: [
        // Circular Progress Indicators with Percentages and Labels Below
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularIndicator(
                  'Approved', Colors.green, approvedPercentage),
              Spacer(),
              _buildCircularIndicator(
                  'Pending', Colors.blue, pendingPercentage),
              Spacer(),
              _buildCircularIndicator(
                  'Rejected', Colors.red, rejectedPercentage),
            ],
          ),
        ),
        SizedBox(height: 30),
        // Bar Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: BarChart(
              BarChartData(
                barGroups: barChartGroups(chartData),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Center(
                              child: Text(
                                chartData[index].x,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
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
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
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
        SizedBox(
          height: 50,
        )
      ],
    );
  }
}

// Widget 2 - Different content
class Widget2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current Salary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                'Current Salary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                '₹80,000', // Placeholder for current salary
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),

        // Salary Breakdown - Bar Chart
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salary Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 60000,
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 50000, // Placeholder for Basic Salary
                            color: Colors.blue,
                            width: 15,
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 15000, // Placeholder for HRA
                            color: Colors.green,
                            width: 15,
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 10000, // Placeholder for Other Allowances
                            color: Colors.orange,
                            width: 15,
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: 5000, // Placeholder for Deductions
                            color: Colors.red,
                            width: 15,
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2),
      ],
    );
  }
}

// Widget 3 - Different content

class Widget3 extends StatefulWidget {
  final List<Receipt> receipts;

  const Widget3({super.key, required this.receipts});

  @override
  _Widget3State createState() => _Widget3State();
}

class _Widget3State extends State<Widget3> {
  GetReceiptResponse? getReceiptResponse;
  ReceiptByStatus? _receiptData;
  final ApiService _apiService = ApiService();
  late bool loading;
  String? error;

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id') ?? '0'; // Default to 0 if not found
    final data = await _apiService.fetchReceiptsByStatus(int.parse(userId));
    setState(() {
      _receiptData = data;
    });
  }

  void _navigateToDetailScreen(String status, List<ReceiptTable> receipts) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailScreen(
          status: status,
          receipts: receipts,
        ),
      ),
    );
  }


  Future getReceiptData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id');
      ApiService apiServices = ApiService();
      getReceiptResponse = await apiServices.getReceipt(userId!);
    } catch (e) {
      error = e.toString();
    }
  }

  void initialize() async {
    setState(() {
      loading = true;
    });
    await getReceiptData();
    await _fetchData();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loading = false;
    initialize();
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Receipt> receipts = widget.receipts;
    final Map<String, Map> monthlyData = {};
    // Group and categorize receipts by month and status
    for (var receipt in receipts) {
      final DateTime receiptDate = DateTime.parse(receipt.createdAt!);
      final String monthYear = DateFormat.yMMM().format(receiptDate);
      final String status =
          receipt.receiptStatus!.toLowerCase(); // Convert status to lowercase

      if (!monthlyData.containsKey(monthYear)) {
        monthlyData[monthYear] = {
          'approved': 0,
          'pending': 0,
          'rejected': 0,
        };
      }

      if (status == 'approved') {
        monthlyData[monthYear]!['approved'] =
            monthlyData[monthYear]!['approved']! + 1;
      } else if (status == 'pending') {
        monthlyData[monthYear]!['pending'] =
            monthlyData[monthYear]!['pending']! + 1;
      } else if (status == 'rejected') {
        monthlyData[monthYear]!['rejected'] =
            monthlyData[monthYear]!['rejected']! + 1;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Totals Section
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Transaction Summary",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Card 1
                          GestureDetector(
                            onTap: () {
                              _navigateToDetailScreen('Approved', _receiptData!.approvedReceipts);
                            },
                            child: Card(
                              color: Colors.green[50],
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "${getReceiptResponse?.approvedReceipts}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                    const Text(
                                      "Approved\nReceipts",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Card 2
                          GestureDetector(
                            onTap: () {
                              _navigateToDetailScreen('Pending', _receiptData!.pendingReceipts);
                            },
                            child: Card(
                              color: Colors.yellow[50],
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "${getReceiptResponse?.pendingReceipts}",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow[
                                              700] // Change color here
                                          ),
                                    ),
                                    Text(
                                      "Pending\nReceipts",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.yellow[700],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Card 3
                          GestureDetector(
                            onTap: () {
                              _navigateToDetailScreen('Rejected', _receiptData!.rejectedReceipts);
                            },
                            child: Card(
                              color: Colors.red[50],
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "${getReceiptResponse?.rejectedReceipts}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      "Rejected\nReceipts",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        // Toggle Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Monthly Breakdown'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF4769B2),
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content Based on Toggle
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IndexedStack(
              index: _currentIndex,
              children: [
                // Monthly Breakdown
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthlyData.keys.length,
                  itemBuilder: (context, index) {
                    final monthYear = monthlyData.keys.elementAt(index);
                    final data = monthlyData[monthYear]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            monthYear,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Approved',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 14),
                                  ),
                                  Text(data['approved'].toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Pending',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.yellow[700],
                                        fontSize: 14),
                                  ),
                                  Text(data['pending'].toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Rejected',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(data['rejected'].toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 70),
      ],
    );
  }
}

class ChartSampleData {
  final String x;
  final int approved;
  final int pending;
  final int rejected;

  ChartSampleData({
    required this.x,
    required this.approved,
    required this.pending,
    required this.rejected,
  });
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
        style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
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
          toY: data.approved.toDouble(),
          color: Colors.green,
          width: 20,
        ),
        BarChartRodData(
          toY: data.pending.toDouble(),
          color: Colors.blue,
          width: 20,
        ),
        BarChartRodData(
          toY: data.rejected.toDouble(),
          color: Colors.red,
          width: 20,
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
}


