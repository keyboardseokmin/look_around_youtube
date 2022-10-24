import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_scraping.dart';
import 'package:look_around_youtube/web_control.dart';

final GetIt getIt = GetIt.instance;

void init() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<YoutubeScraping>(YoutubeScraping());
  getIt.registerLazySingleton<WebControl>(() => WebControl());
}