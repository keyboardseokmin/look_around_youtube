
import 'package:flutter/material.dart';
import 'package:look_around_youtube/ui/home_screen.dart';
import 'package:look_around_youtube/ui/login_screen.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/home_bloc.dart';
import '../bloc/login_bloc.dart';

class NavigationScreen extends StatelessWidget {
  final int initialIndex;

  const NavigationScreen({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: Scaffold(
          body: SafeArea(
            child: TabBarView(
              children: [
                BlocProvider<HomeBloc>(
                  bloc: HomeBloc(),
                  child: const HomeScreen()
                ),
                BlocProvider<LoginBloc>(
                    bloc: LoginBloc(),
                    child: const LoginScreen()
                ),
              ],
            ),
          ),
          bottomNavigationBar: const TabBar(
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