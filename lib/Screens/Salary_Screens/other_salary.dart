import 'dart:math';
import 'package:flutter/material.dart';
import 'add_promotion.dart';

class SalaryAnalysisScreen extends StatefulWidget {
  @override
  _SalaryAnalysisScreenState createState() => _SalaryAnalysisScreenState();
}

class _SalaryAnalysisScreenState extends State<SalaryAnalysisScreen> {
  final int totalMonths = 12; // Total number of months to show
  int _currentStep = 0; // Default to the first month
  final double initialSalary = 100.00; // Initial salary
  final double incrementRate = 0.03; // 3% increase per year

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  double _calculateSalary(int year) {
    // Calculate the salary with a 3% increase each year
    int yearsElapsed = year - _currentYear;
    return initialSalary * pow(1 + incrementRate, yearsElapsed);
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4769B2),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Salary Analysis',
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Stepper(
                physics: ClampingScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
                onStepContinue: () {
                  if (_currentStep < totalMonths - 1) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                steps: List.generate(
                  totalMonths, // Generate steps for each month
                      (index) {
                    final monthIndex = (_currentMonth - 1 + index) % 12;
                    final year = _currentYear + ((_currentMonth - 1 + index) ~/ 12);
                    final salary = _calculateSalary(year);

                    return Step(
                      title: Text('${months[monthIndex]}, $year'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salary: ₹${salary.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '3.00% Increase Annually',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep == index,
                      state: _currentStep == index
                          ? StepState.editing
                          : _currentStep > index
                          ? StepState.complete
                          : StepState.indexed,
                    );
                  },
                ),
              ),
            ),
          ),

          // Button at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddPromotionForm()));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
                backgroundColor: Color(0xFF4769B2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Promotion',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
