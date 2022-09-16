import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/home_bloc.dart';
import '../data/datasource/youtube_channel_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: OutlinedButton(onPressed: () {
                      bloc.isEmptyCurrentUser()? bloc.googleSignIn(): bloc.googleSignOut();
                    }, child: _buildIDButton(bloc))),
                Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: OutlinedButton(onPressed: () {}, child: const Text('Settings'))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _buildVideoList(bloc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIDButton(HomeBloc bloc) {
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
            return _videoList(snapshot.data!);
          }
        }
    );
  }

  Widget _videoList(List<YoutubeChannelData> list) {
    return List
  }
}