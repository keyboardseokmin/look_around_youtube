
import '../../data/datasource/remote/youtube_rest_api.dart';
import '../../injection_container.dart';

class MainViewModel {
  final youtubeApi = getIt<YoutubeRestApi>();


}