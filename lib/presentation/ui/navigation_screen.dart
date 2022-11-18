
import 'package:flutter/material.dart';
import 'package:look_around_youtube/presentation/ui/login_screen.dart';
import 'package:look_around_youtube/presentation/ui/music_screen.dart';

class NavigationScreen extends StatelessWidget {
  final int initialIndex;

  const NavigationScreen({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: const Scaffold(
          body: SafeArea(
            child: TabBarView(
              children: [
                MusicScreen(),
                LoginScreen()
              ],
            ),
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                text: 'music',
              ),
              Tab(
                text: 'me',
              ),
            ],
          ),
        )
    );
  }
}