
import 'package:flutter/material.dart';
import 'package:look_around_youtube/ui/home_screen.dart';
import 'package:look_around_youtube/ui/login_screen.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: TabBarView(
              children: [
                HomeScreen(),
                LoginScreen()
              ],
            ),
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                text: 'home',
              ),
              Tab(
                text: 'user',
              )
            ],
          ),
        )
    );
  }
}