import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:look_around_youtube/web_control.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/home_bloc.dart';
import '../data/datasource/remote/youtube_scraping.dart';
import '../data/datasource/youtube_data.dart';
import '../injection_container.dart';
import 'app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);
    bloc.loadVideos();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildYoutubePlayer(bloc),
            _buildVideoEmptyMessage(bloc),
            _buildVideoList(bloc),
            _buildPlayerButtons(bloc),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubePlayer(HomeBloc bloc) {
    return StreamBuilder<bool>(
        stream: bloc.showYoutubeVideoStream,
        builder: (context, snapshot) {
          return Visibility(
            visible: (snapshot.data == true),
            child: StreamBuilder<YoutubePlayerController>(
              stream: bloc.youtubePlayerControllerStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return YoutubePlayer(
                    controller: snapshot.data!,
                    showVideoProgressIndicator: true,
                    onReady: () {},
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        }
    );
  }

  Widget _buildVideoEmptyMessage(HomeBloc bloc) {
    return StreamBuilder<bool>(
      stream: bloc.showVideoEmptyMessageStream,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Expanded(child: Center(child: Text("${"empty".tr()} \u{1F622}")));
        } else {
          return Container();
        }
      }
    );
  }

  Widget _buildVideoList(HomeBloc bloc) {
    return StreamBuilder<List<YoutubeVideoData>>(
      stream: bloc.videoListStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            const snackBar = SnackBar(content: Text('에러: 구독 정보를 가져올 수 없습니다'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
          return Container();
        } else if (snapshot.data == null) {
          return Container();
        } else if (snapshot.hasData == false) {
          return const CircularProgressIndicator();
        } else {
          return Expanded(child: _YoutubeVideoList(videoList: snapshot.data!));
        }
      },
    );
  }

  Widget _buildPlayerButtons(HomeBloc bloc) {
    return StreamBuilder<bool>(
      stream: bloc.showControlButtonsStream,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  bloc.previousVideo();
                },
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              IconButton(
                onPressed: () {
                  bloc.rewindVideo(bloc.videoJumpSecond);
                },
                icon: const Icon(Icons.fast_rewind_rounded),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black87,
                child: IconButton(
                  onPressed: () {},
                  // pause_rounded
                  icon: const Icon(Icons.play_arrow_rounded),
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  bloc.forwardVideo(bloc.videoJumpSecond);
                },
                icon: const Icon(Icons.fast_forward_rounded),
              ),
              IconButton(
                onPressed: () {
                  bloc.nextVideo();
                },
                icon: const Icon(Icons.skip_next_rounded),
              ),
              const SizedBox(width: 10),
            ],
          );
        } else {
          return Container();
        }
      }
    );
  }
}

class _YoutubeVideoList extends StatelessWidget {
  final List<YoutubeVideoData> videoList;

  const _YoutubeVideoList({Key? key, required this.videoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return ListView.separated(
        controller: bloc.scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: videoList.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              bloc.setYoutubePlayerController(index);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    videoList[index].title,
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
                        videoList[index].channel,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                      ),
                      Text(
                        videoList[index].publishedAt,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                      ),
                    ],
                  ),
                )
              ]),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.grey
        ),
    );
  }
}
