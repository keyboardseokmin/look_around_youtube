import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/youtube_data.dart';
import '../../provider/providers.dart';
import '../app_colors.dart';
import '../app_fonts.dart';
import 'draggable_floating_button.dart';
import 'option_screen.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  MusicScreenState createState() {
    return MusicScreenState();
  }
}

class MusicScreenState extends ConsumerState<MusicScreen> {
  final GlobalKey _parentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 첫 생성시 비디오 목록 로드
    ref.read(musicProvider).loadVideos();
    // 유저 정보 로드, webview running 타이밍 맞추기
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(musicProvider).getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoList = ref.watch(filteredVideoList);

    return WillPopScope(
      onWillPop: () {
        return _onBackKey();
      },
      child: Scaffold(
        body: SafeArea(
          key: _parentKey,
          child: Stack(
            children: [
              Column(
                children: [
                  videoList.isNotEmpty ? _buildYoutubePlayer(ref) : Container(),
                  videoList.isEmpty ? _buildVideoEmptyMessage() :  Container(),
                  videoList.isNotEmpty ? _buildVideoList(videoList) : Container(),
                ],
              ),
              videoList.isNotEmpty ? _buildPlayerButtons(context) : Container(),
              const ExpandContainer(),
              _buildBottomIndicator(ref),
            ]
          ),
        ),
      ),
    );
  }

  Timer? timerBackToBackKey;
  Future<bool> _onBackKey() async {
    if (ref.read(isOptionShowed)) {
      ref.read(isOptionShowed.notifier).state = false;
      return false;
    }

    if (ref.read(backKeyPressed)) {
      return true;
    }

    ref.read(backKeyPressed.notifier).update((state) => true);
    timerBackToBackKey?.cancel();
    timerBackToBackKey = Timer(const Duration(seconds: 4), () {
      ref.read(backKeyPressed.notifier).update((state) => false);
    });
    
    Fluttertoast.showToast(
      msg: "back".tr(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM
    );
    return false;
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
            key: listOfVideos[index].key,
            onTap: () {
              ref.read(musicProvider).setYoutubePlayerController(index);
              // 스크롤 이동
              // ref.read(musicProvider).moveToScroll(index);
            },
            child: Container(
              // 선택하면 백그라운드가 그레이로 바뀜
              // decoration: BoxDecoration(
              //   color: ref.watch(currentIndexProvider) == index ?
              //   AppColors.listSelected :
              //   AppColors.grey,
              //   borderRadius: const BorderRadius.all(Radius.circular(6))
              // ),
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
                        style: AppFonts.listViewMain,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        width: calcTextSize(listOfVideos[index].title, AppFonts.listViewMain).width,
                        height: 3,
                        color: ref.watch(currentIndexProvider) == index ? Colors.black87 : AppColors.grey,
                      )
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            listOfVideos[index].channel,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppFonts.listViewSub,
                          ),
                          Text(
                            listOfVideos[index].publishedAt,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppFonts.listViewSub,
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

  Widget _buildPlayerButtons(BuildContext context) {
    return DraggableFloatingButton(
      initialOffset: _getInitOffset(context),
      onPressed: () {  },
      parentKey: _parentKey,
      child: Column(
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
      ),
    );
  }

  Offset _getInitOffset(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final width = MediaQuery.of(context).size.width;
    return Offset(width * 0.75, (height - padding.top - padding.bottom) * 0.44);
  }

  Widget _buildPlayPauseIcon() {
    switch(ref.watch(playerStateProvider)) {
      case PlayerState.playing:
        return const Icon(Icons.pause_rounded);
      default:
        return const Icon(Icons.play_arrow_rounded);
    }
  }

  Size calcTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textScaleFactor: WidgetsBinding.instance.window.textScaleFactor,
    )..layout();
    return textPainter.size;
  }

  Widget _buildBottomIndicator(WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(showBottomIndicator) ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedAlign(
        alignment: Alignment(
          Alignment.bottomCenter.x,
          ref.watch(showBottomIndicator) ? Alignment.bottomCenter.y - 0.01 : Alignment.bottomCenter.y + 0.1
        ),
        duration: const Duration(milliseconds: 200),
        child: const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 3.0,
          ),
        ),
      ),
    );
  }
}

// 하단 플로팅 버튼
class ExpandContainer extends ConsumerWidget {
  const ExpandContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return AnimatedAlign(
      alignment: Alignment(
        Alignment.bottomCenter.x,
        ref.watch(isOptionShowed) ? Alignment.bottomCenter.y : Alignment.bottomCenter.y - 0.13
      ),
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: () {
          if (!ref.read(isOptionShowed)) {
            ref.read(isOptionShowed.notifier).update((state) => !state);
          }
        },
        child: AnimatedContainer(
          width: ref.watch(isOptionShowed) ? screenSize.width : 140,
          height: ref.watch(isOptionShowed) ? screenSize.height - padding.top - padding.bottom: 50,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: ref.watch(isOptionShowed) ? Colors.white : Colors.black87,
            borderRadius: ref.watch(isOptionShowed) ?
            const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)) :
            const BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                spreadRadius: 0,
                blurRadius: 5.0,
                offset: const Offset(0, 4),
              ),
            ]
          ),
          curve: Curves.fastOutSlowIn,
          child: ref.watch(isOptionShowed) ?
          const OptionScreen() :
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              ref.watch(userProvider).photo == "" ?
              ClipOval(
                child: Container(
                  width: 26,
                  height: 26,
                  color: Colors.white70,
                ),
              ) :
              ClipOval(
                child: CachedNetworkImage(
                  width: 26,
                  height: 26,
                  imageUrl: ref.read(userProvider).photo,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  ref.watch(userProvider).nickname,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.floatingName,
                ),
              ),
              const SizedBox(
                width: 18,
              )
            ],
          ),
        ),
      ),
    );
  }
}
