import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:look_around_youtube/data/datasource/local/subscribes_data_source.dart';
import 'package:look_around_youtube/presentation/app_colors.dart';
import 'package:look_around_youtube/presentation/ui/intro.dart';

import 'data/datasource/local/subscribe_data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Hive 초기화
  await Hive.initFlutter();
  Hive.registerAdapter(SubscribeDataAdapter());
  await SubscribeDataSource.init();
  runApp(
    // 언어설정
    EasyLocalization(
        // 지원 언어 리스트
        supportedLocales: const [Locale('en'), Locale('ko')],
        path: 'assets/translations',
        // 지원 언어 이외의 시작 언어
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(child: MyApp())
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w700BitterFont = GoogleFonts.bitter(
      fontWeight: FontWeight.w700,
    );

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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
      home: const Intro(),
    );
  }
}