import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/home_bloc.dart';
import '../data/datasource/remote/youtube_scraping.dart';
import '../data/datasource/youtube_data.dart';
import '../injection_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);
    final youtubeScraping = getIt<YoutubeScraping>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //         padding: const EdgeInsets.only(left: 20),
            //         child: OutlinedButton(onPressed: () {
            //           bloc.isEmptyCurrentUser()? bloc.googleSignIn(): bloc.googleSignOut();
            //         }, child: _buildIDButtonText(bloc))),
            //     Padding(
            //         padding: const EdgeInsets.only(right: 20),
            //         child: OutlinedButton(onPressed: () {}, child: const Text('Settings'))),
            //   ],
            // ),
            // const SizedBox(height: 20),
            _buildYoutubePlayer(bloc),
            const SizedBox(height: 10),
            // _buildVideoList(bloc)
            Expanded(child:
              InAppWebView(
                initialUrlRequest: youtubeScraping.initUri,
                initialOptions: youtubeScraping.options,
                onWebViewCreated: (controller) {
                  youtubeScraping.webViewController = controller;
                },
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStop: (controller, url) {
                  debugPrint(url.toString());
                  youtubeScraping.parseUrlAction(controller, url);
                },
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubePlayer(HomeBloc bloc) {
    return StreamBuilder<bool>(
        stream: bloc.showYoutubeVideoStream,
      builder: (context, snapshot) {
          if (snapshot.data == true) {
            return YoutubePlayer(
              controller: bloc.controller,
              showVideoProgressIndicator: true,
            );
          } else {
            return Container();
          }
      }
    );
  }

  Widget _buildIDButtonText(HomeBloc bloc) {
    return StreamBuilder<GoogleSignInAccount?>(
      stream: bloc.currentUserStream,
      builder: (context, snapshot) {
        final results = snapshot.data;
        if (results == null) {
          return const Text('SignIn Youtube');
        } else {
          return Text(results.email);
        }
      },
    );
  }

  Widget _buildVideoList(HomeBloc bloc) {
    return StreamBuilder<List<YoutubeChannelData>>(
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
        }
    );
  }
}

class _YoutubeVideoList extends StatelessWidget {
  final List<YoutubeChannelData> videoList;

  const _YoutubeVideoList({Key? key, required this.videoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: videoList.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(videoList[index].name),
              ),
            ],);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.grey
        ),
    );
  }
}