import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_rest_api.dart';

final GetIt getIt = GetIt.instance;

void init() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<YoutubeRestApi>(YoutubeRestApi());
}