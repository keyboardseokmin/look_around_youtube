import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_scraping.dart';
import 'package:look_around_youtube/web_control.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../data/datasource/youtube_data.dart';
import '../injection_container.dart';
import 'bloc.dart';

class HomeBloc implements Bloc {
  final _api = getIt<YoutubeScraping>();
  final _webControl = getIt<WebControl>();

  final youtubeUrlPrefix = "watch?v=";
  final youtubeVideoList = <YoutubeVideoData>[];

  var startSecondAtVideo = 30;
  var videoJumpSecond = 10;
  int? _currentIndex = 0;

  final scrollController = ScrollController();

  // Youtube Player 관련
  // Youtube Player Controller
  YoutubePlayerController? nowController;
  final _youtubePlayerController = StreamController<YoutubePlayerController>();
  Stream<YoutubePlayerController> get youtubePlayerControllerStream => _youtubePlayerController.stream;
  // 새로운 video list
  final _videoList = <YoutubeVideoData>[];
  final _videoListController = StreamController<List<YoutubeVideoData>>();
  Stream<List<YoutubeVideoData>> get videoListStream => _videoListController.stream;
  // youtube player 보여줄지 유무
  final _showYoutubeVideo = StreamController<bool>()..add(false);
  Stream<bool> get showYoutubeVideoStream => _showYoutubeVideo.stream;
  // video empty message 보여줄지 유무
  final _showVideoEmptyMessage = StreamController<bool>()..add(false);
  Stream<bool> get showVideoEmptyMessageStream => _showVideoEmptyMessage.stream;
  // 영상 재생 관련 버튼 보여줄지 유무
  final _showControlButtons = StreamController<bool>()..add(false);
  Stream<bool> get showControlButtonsStream => _showControlButtons.stream;

  @override
  void deactivate() {
    nowController?.pause();
  }

  @override
  void dispose() {
    nowController?.dispose();
  }

  void loadVideos() {
    _api.getListOfVideo(_webControl.webViewController);
  }

  // webView page load 후 로직 처리
  void parseUrlAction(InAppWebViewController controller, Uri? url) async {
    final type = _api.getLoadType(url);
    if (type == null) return;

    switch (type) {
      case LoadUrlType.signIn:
        break;
      case LoadUrlType.listOfVideo:
        _listOfVideo(controller);
        break;
      case LoadUrlType.userInfo:
        break;
      case LoadUrlType.isLogin:
        break;
      case LoadUrlType.logOut:
        break;
    }
  }

  void _listOfVideo(InAppWebViewController controller) async {
    final listOfVideo = await _api.parseGetListOfVideo(controller);
    final listOfYoutubeVideo = getListOfYoutubeVideo(listOfVideo);

    // 영상 리스트가 있는지 확인
    if (listOfYoutubeVideo.isNotEmpty) {
      // controller 정리 및 생성
      final videoId = YoutubePlayer.convertUrlToId(listOfYoutubeVideo.first.videoUrl);
      if (videoId != null) {
        if (nowController == null) {
          nowController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              enableCaption: false,
              hideControls: false,
              hideThumbnail: true,
              startAt: 30,
            ),
          );
          _youtubePlayerController.add(nowController!);
          _currentIndex = 0;
        } else {
          nowController?.load(videoId, startAt: startSecondAtVideo);
          _currentIndex = 0;
        }
      }

      showVideoAndButtons();
      _showVideoEmptyMessage.add(false);
    } else {
      // 영상 리스트가 비었을 경우
      hideVideoAndButtons();
      _showVideoEmptyMessage.add(true);
    }
    // 영상 리스트 업데이트
    _videoList.clear();
    _videoList.addAll(listOfYoutubeVideo);
    _videoListController.add(listOfYoutubeVideo);
  }

  void hideVideoAndButtons() {
    _showYoutubeVideo.add(false);
    _showControlButtons.add(false);
  }

  void showVideoAndButtons() {
    _showYoutubeVideo.add(true);
    _showControlButtons.add(true);
  }

  List<YoutubeVideoData> getListOfYoutubeVideo(List<dynamic> list) {
    final result = <YoutubeVideoData>[];
    for (final video in list) {
      if (video is List) {
        if (video.length > 3) {
          // 유튜브 영상이 아니라 shorts 는 걸러냄, 향후 player 버전에서 지원할 가능성 있음
          if (!video[3].toString().contains(youtubeUrlPrefix)) continue;
          // 실시간 방송은 스크래핑에서 info.length 가 2라서 채널과 시간값이 0이 들어감
          if (video[1] == "" && video[2] == "") continue;
          result.add(YoutubeVideoData(video[0], video[1], video[2], video[3]));
        }
      }
    }
    return result;
  }

  // video list 에 있는 영상 선택
  void setYoutubePlayerController(int index) {
    if (index < _videoList.length && index >= 0) {
      // nowController?.pause();
      final videoId = YoutubePlayer.convertUrlToId(_videoList[index].videoUrl);
      if (videoId != null) {
        nowController?.load(videoId, startAt: startSecondAtVideo);
        _currentIndex = index;
      }
    }
  }

  // 뒤로 second 초 만큼
  void rewindVideo(int second) {
    if (nowController != null) {
      final currentTime = nowController!.value.position;
      nowController!.seekTo(currentTime + Duration(seconds: -second));
    }
  }
  // 뒤로 second 초 만큼
  void forwardVideo(int second) {
    if (nowController != null) {
      final currentTime = nowController!.value.position;
      nowController!.seekTo(currentTime + Duration(seconds: second));
    }
  }

  // 이전 영상
  void previousVideo() {
    if (nowController != null && _currentIndex != null && _currentIndex != 0) {
      final videoId = YoutubePlayer.convertUrlToId(_videoList[_currentIndex! - 1].videoUrl);
      if (videoId != null) {
        nowController?.load(videoId, startAt: startSecondAtVideo);
        _currentIndex = _currentIndex! - 1;
      }
    }
  }
  // 다음 영상
  void nextVideo() {
    if (nowController != null && _currentIndex != null && _currentIndex != _videoList.length - 1) {
      final videoId = YoutubePlayer.convertUrlToId(_videoList[_currentIndex! + 1].videoUrl);
      if (videoId != null) {
        nowController?.load(videoId, startAt: startSecondAtVideo);
        _currentIndex = _currentIndex! + 1;
      }
    }
  }
}