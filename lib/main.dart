import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:look_around_youtube/bloc/bloc_provider.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_rest_api.dart';
import 'package:look_around_youtube/ui/app_colors.dart';
import 'package:look_around_youtube/ui/home_screen.dart';
import 'bloc/home_bloc.dart';
import 'injection_container.dart' as ic;


void main() async {
  ic.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w700BitterFont = GoogleFonts.bitter(
      fontWeight: FontWeight.w700,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Look around Youtube',
      theme: ThemeData(
        primarySwatch: AppColors.black,
        primaryColor: AppColors.black,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          secondary: AppColors.green,
          primary: AppColors.black,
        ),
        scaffoldBackgroundColor: AppColors.grey,
        backgroundColor: AppColors.grey,
        primaryTextTheme: TextTheme(
          headline6: w700BitterFont,
        ),
        textTheme: TextTheme(
          subtitle1: w700BitterFont.apply(color: AppColors.black),
          headline6: w700BitterFont.apply(color: AppColors.black),
          bodyText2: TextStyle(color: AppColors.black),
        ),
      ),
      home: BlocProvider<HomeBloc>(
        bloc: HomeBloc(),
        child: const HomeScreen(),
      ),
    );
  }
}
