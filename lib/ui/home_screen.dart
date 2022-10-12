import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/home_bloc.dart';
import '../data/datasource/youtube_data.dart';
import 'app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildWebView(bloc),
            _buildYoutubePlayer(bloc),
            _buildVideoList(bloc),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(HomeBloc bloc) {
    return StreamBuilder<bool>(
      stream: bloc.showWebViewStream,
      builder: (context, snapshot) {
        return Visibility(
            visible: (snapshot.data == true),
            child: Expanded(child:
            InAppWebView(
              initialUrlRequest: bloc.initUri,
              initialOptions: bloc.options,
              onWebViewCreated: (controller) {
                bloc.webViewController = controller;
              },
              androidOnPermissionRequest: (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
              onLoadStop: (controller, url) {
                debugPrint(url.toString());
                bloc.parseUrlAction(controller, url);
              },
            )
            )
        );
      },
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
}

class _YoutubeVideoList extends StatelessWidget {
  final List<YoutubeVideoData> videoList;

  const _YoutubeVideoList({Key? key, required this.videoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return ListView.separated(
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
