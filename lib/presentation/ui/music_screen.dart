import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/youtube_data.dart';
import '../../provider/providers.dart';
import '../app_colors.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  MusicScreenState createState() {
    return MusicScreenState();
  }
}

class MusicScreenState extends ConsumerState<MusicScreen> {
  @override
  void initState() {
    super.initState();
    // 첫 생성시 비디오 목록 로드
    ref.read(musicProvider).loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    final videoList = ref.watch(videoListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            videoList.isNotEmpty ? _buildYoutubePlayer(ref) : Container(),
            videoList.isEmpty ? _buildVideoEmptyMessage() :  Container(),
            videoList.isNotEmpty ? _buildVideoList(videoList) : Container(),
            videoList.isNotEmpty ? _buildPlayerButtons() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubePlayer(WidgetRef ref) {
    return YoutubePlayer(
      controller: ref.read(musicProvider).playerController,
      showVideoProgressIndicator: true,
      onReady: () {
        ref.read(musicProvider).setYoutubePlayerController(0);
      },
    );
  }

  Widget _buildVideoEmptyMessage() {
    return Expanded(child: Center(child: Text("${"empty".tr()} \u{1F622}")));
  }

  Widget _buildVideoList(List<YoutubeVideoData> listOfVideos) {
    return Expanded(
      child: ListView.separated(
        controller: ref.read(musicProvider).scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: listOfVideos.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              ref.read(musicProvider).setYoutubePlayerController(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: ref.watch(currentIndex) == index ?
                AppColors.listSelected :
                AppColors.grey,
                borderRadius: const BorderRadius.all(Radius.circular(6))
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        listOfVideos[index].title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            listOfVideos[index].channel,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                          ),
                          Text(
                            listOfVideos[index].publishedAt,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  ]),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
            color: Colors.grey
        ),
      )
    );
  }

  Widget _buildPlayerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            ref.read(musicProvider).previousVideo();
          },
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        IconButton(
          onPressed: () {
            final time = ref.read(videoJumpSecondProvider);
            ref.read(musicProvider).rewindVideo(time);
          },
          icon: const Icon(Icons.fast_rewind_rounded),
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black87,
          child: IconButton(
            onPressed: () {
              ref.read(musicProvider).playOrPause();
            },
            icon: _buildPlayPauseIcon(),
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            final time = ref.read(videoJumpSecondProvider);
            ref.read(musicProvider).forwardVideo(time);
          },
          icon: const Icon(Icons.fast_forward_rounded),
        ),
        IconButton(
          onPressed: () {
            ref.read(musicProvider).nextVideo();
          },
          icon: const Icon(Icons.skip_next_rounded),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildPlayPauseIcon() {
    switch(ref.watch(playerState)) {
      case PlayerState.playing:
        return const Icon(Icons.pause_rounded);
      default:
        return const Icon(Icons.play_arrow_rounded);
    }
  }
}
