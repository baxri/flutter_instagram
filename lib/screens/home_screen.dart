import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/screens/screens.dart';
import 'package:provider/provider.dart';

import '../state/UserState.dart';

class HomeScreen extends StatefulWidget {
  static const String id = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = Provider.of<UserState>(context).currentUserId;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          FeedScreen(userId: userId),
          SearchScreen(),
          CreatePostScreen(pageController: _pageController),
          NotificationsScreen(),
          ProfileScreen(userId: userId),
        ],
        onPageChanged: (index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() {
          _currentTab = index;
          _pageController.animateToPage(
            _currentTab,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }),
        activeColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
            Icons.home,
            size: 28.0,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.search,
            size: 28.0,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 28.0,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.notifications,
            size: 28.0,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.account_circle,
            size: 28.0,
          ))
        ],
      ),
    );
  }
}
