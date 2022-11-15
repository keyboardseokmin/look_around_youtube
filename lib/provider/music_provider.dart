import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:look_around_youtube/provider/providers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../data/youtube_data.dart';

class Music {
  // video listView scroll controller
  final scrollController = ScrollController();
  // Youtube Player 관련
  late final YoutubePlayerController playerController;

  final Ref ref;

  Music(this.ref) {
    playerController = YoutubePlayerController(
      initialVideoId: '',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: false,
        hideControls: false,
        hideThumbnail: true,
        startAt: ref.read(startSecondAtVideoProvider),
      ),
    );
    playerController.addListener(() {
      ref.read(playerState.notifier).state = playerController.value.playerState;
      debugPrint(ref.read(playerState.notifier).state.toString());
    });
  }

  void loadVideos() {
    ref.read(headlessWebViewProvider).getListOfVideo();
  }

  // video list 에 있는 영상 선택
  void setYoutubePlayerController(int index) {
    final videoList = ref.read(videoListProvider);
    if (index < videoList.length && index >= 0) {
      // nowController?.pause();
      final videoId = YoutubePlayer.convertUrlToId(videoList[index].videoUrl);
      if (videoId != null) {
        playerController.load(videoId, startAt: ref.read(startSecondAtVideoProvider));
        ref.read(currentIndex.notifier).state = index;
      }
    }
  }

  // 재생/일시정지
  void playOrPause() {
    if (playerController.value.isPlaying) {
      playerController.pause();
    } else {
      playerController.play();
    }
  }

  // 뒤로 second 초 만큼
  void rewindVideo(int second) {
    final currentTime = playerController.value.position;
    playerController.seekTo(currentTime + Duration(seconds: -second));
  }
  // 뒤로 second 초 만큼
  void forwardVideo(int second) {
    final currentTime = playerController.value.position;
    playerController.seekTo(currentTime + Duration(seconds: second));
  }

  // 이전 영상
  void previousVideo() {
    final index = ref.read(currentIndex);
    if (index != null && index != 0) {
      final videoId = YoutubePlayer.convertUrlToId(ref.read(videoListProvider)[index - 1].videoUrl);
      if (videoId != null) {
        playerController.load(videoId, startAt: ref.read(startSecondAtVideoProvider));
        ref.read(currentIndex.notifier).update((state) => state! - 1);
      }
    }
  }
  // 다음 영상
  void nextVideo() {
    final index = ref.read(currentIndex);
    if (index != null && index != ref.read(videoListProvider).length - 1) {
      final videoId = YoutubePlayer.convertUrlToId(ref.read(videoListProvider)[index! + 1].videoUrl);
      if (videoId != null) {
        playerController.load(videoId, startAt: ref.read(startSecondAtVideoProvider));
        ref.read(currentIndex.notifier).update((state) => state! + 1);
      }
    }
  }
}