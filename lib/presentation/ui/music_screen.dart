import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/youtube_data.dart';
import '../../provider/providers.dart';
import '../app_colors.dart';
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
    final videoList = ref.watch(videoListProvider);

    return Scaffold(
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
          ]
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
            key: listOfVideos[index].key,
            onTap: () {
              ref.read(musicProvider).setYoutubePlayerController(index);
              // 스크롤 이동
              // ref.read(musicProvider).moveToScroll(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: ref.watch(currentIndexProvider) == index ?
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

  Widget _buildPlayerButtons(BuildContext context) {
    return DraggableFloatingActionButton(
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
}

class DraggableFloatingActionButton extends StatefulWidget {

  final Widget child;
  final Offset initialOffset;
  final VoidCallback onPressed;
  final GlobalKey parentKey;

  const DraggableFloatingActionButton({
    super.key,
    required this.child,
    required this.initialOffset,
    required this.onPressed,
    required this.parentKey
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState extends State<DraggableFloatingActionButton> {

  final GlobalKey _key = GlobalKey();

  bool _isDragging = false;
  late Offset _offset;
  late Offset _minOffset;
  late Offset _maxOffset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;

    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
  }

  void _setBoundary(_) {
    final RenderBox parentRenderBox = widget.parentKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;

    try {
      final Size parentSize = parentRenderBox.size;
      final Size size = renderBox.size;

      setState(() {
        _minOffset = const Offset(0, 0);
        _maxOffset = Offset(
            parentSize.width - size.width,
            parentSize.height - size.height
        );
      });
    } catch (e) {
      debugPrint('catch: $e');
    }
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
      debugPrint(_offset.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);

          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          if (_isDragging) {
            setState(() {
              _isDragging = false;
            });
          } else {
            widget.onPressed();
          }
        },
        child: Container(
          key: _key,
          child: widget.child,
        ),
      ),
    );
  }
}

// 하단 플로팅 버튼
class ExpandContainer extends ConsumerStatefulWidget {
  const ExpandContainer({Key? key}) : super(key: key);

  @override
  ExpandContainerState createState() => ExpandContainerState();
}

class ExpandContainerState extends ConsumerState<ExpandContainer> {
  var isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedAlign(
      alignment: Alignment(
        Alignment.bottomCenter.x,
        isExpanded ? Alignment.bottomCenter.y : Alignment.bottomCenter.y - 0.04
      ),
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: AnimatedContainer(
          width: isExpanded ? screenSize.width : 200,
          height: isExpanded ? screenSize.height : 50,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isExpanded ? Colors.white : Colors.black87,
            borderRadius: isExpanded ?
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
          child: isExpanded ?
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
            ],
          ),
        ),
      ),
    );
  }
}
