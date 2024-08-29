import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Leaves_Screens/apply_leaves.dart';
import 'Profile_Screens/userprofile_screen.dart';
import 'document_screen.dart';
import 'home_screen.dart';
import 'other_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Main content of the screen
          _getChildren()[_currentIndex],

          // Floating bottom navigation bar with rounded corners
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30), // Rounded corners
              child: Material(
                elevation: 8, // Shadow effect for floating appearance
                color: Colors.transparent,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  backgroundColor: Colors.grey[200],
                  type: BottomNavigationBarType.fixed,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/home.png',
                        width: 24,
                        height: 24,
                        color: _currentIndex == 0 ? Color(0xFF4769B2) : Colors.black,
                      ),
                      label: 'HOME',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/b1.png',
                        width: 24,
                        height: 24,
                        color: _currentIndex == 1 ? Color(0xFF4769B2) : Colors.black,
                      ),
                      label: 'BOOK',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/invoices.png',
                        width: 24,
                        height: 24,
                        color: _currentIndex == 2 ? Color(0xFF4769B2) : Colors.black,
                      ),
                      label: 'receipt',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/more.png',
                        width: 24,
                        height: 24,
                        color: _currentIndex == 3 ? Color(0xFF4769B2) : Colors.black,
                      ),
                      label: 'MORE',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  unselectedLabelStyle: TextStyle(color: Colors.black, fontSize: 14),
                  selectedLabelStyle: TextStyle(color: Color(0xFF4769B2), fontSize: 16),
                  selectedItemColor: Color(0xFF4769B2),
                  unselectedItemColor: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getChildren() {
    return [
      HomeScreen(),
      DocumentUploadScreen(),
      HomeScreen(),
      OtherScreen(),
    ];
  }
}
