import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_scraping.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../data/datasource/youtube_data.dart';
import '../injection_container.dart';
import 'bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomeBloc implements Bloc {
  final _youtubeScraping = getIt<YoutubeScraping>();

  final youtubeUrlPrefix = "https://youtube.com/watch?v=";
  final youtubeVideoList = <YoutubeVideoData>[];

  // WebView 관련
  InAppWebViewController? webViewController;
  final URLRequest initUri = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      )
  );

  // Youtube Player 관련
  YoutubePlayerController? nowController;
  final List<YoutubePlayerController> _listOfController = [];

  final _showWebView = StreamController<bool>()..add(true);
  Stream<bool> get showWebViewStream => _showWebView.stream;
  final _showYoutubeVideo = StreamController<bool>();
  Stream<bool> get showYoutubeVideoStream => _showYoutubeVideo.stream;
  final _videoList = StreamController<List<YoutubeVideoData>>();
  Stream<List<YoutubeVideoData>> get videoListStream => _videoList.stream;
  final _youtubePlayerController = StreamController<YoutubePlayerController>();
  Stream<YoutubePlayerController> get youtubePlayerControllerStream => _youtubePlayerController.stream;

  @override
  void deactivate() {
    nowController?.pause();
  }

  @override
  void dispose() {
    disposeYoutubePlayerController();
  }

  void parseUrlAction(InAppWebViewController controller, Uri? url) async {
    final urlString = url.toString();
    if (urlString.contains('https://m.youtube.com/feed/subscriptions')) {
      if (await _youtubeScraping.goSignInMenu(controller) == false) {
        _showWebView.add(false);
        final listOfVideo = await _youtubeScraping.getListOfVideo(controller);
        final listOfYoutubeVideo = getListOfYoutubeVideo(listOfVideo);
        // controller 정리 및 생성
        disposeYoutubePlayerController();
        _listOfController.clear();
        _listOfController.addAll(createYoutubePlayerController(listOfYoutubeVideo));
        if (_listOfController.isNotEmpty) {
          nowController = _listOfController.first;
          _youtubePlayerController.add(_listOfController.first);
          _showYoutubeVideo.add(true);
        }
        _videoList.add(listOfYoutubeVideo);
      } else {
        _showWebView.sink.add(true);
        _videoList.add(<YoutubeVideoData>[]);
        _showYoutubeVideo.add(false);
      }
    }
  }

  List<YoutubeVideoData> getListOfYoutubeVideo(List<dynamic> list) {
    final result = <YoutubeVideoData>[];
    for (final video in list) {
      if (video is List) {
        if (video.length > 3) {
          result.add(YoutubeVideoData(video[0], video[1], video[2], video[3]));
        }
      }
    }
    return result;
  }

  List<YoutubePlayerController> createYoutubePlayerController(List<YoutubeVideoData> list) {
    final result = <YoutubePlayerController>[];
    for (final data in list) {
      final controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(data.videoUrl) ?? "",
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          enableCaption: false,
        ),
      );
      result.add(controller);
    }
    return result;
  }

  void setYoutubePlayerController(int index) {
    if (index < _listOfController.length) {
      // nowController?.pause();
      nowController?.load(_listOfController[index].initialVideoId);
      // nowController = _listOfController[index];
      // _youtubePlayerController.sink.add(_listOfController[index]);
    }
  }

  void disposeYoutubePlayerController() {
    for (final controller in _listOfController) {
      controller.dispose();
    }
  }
}