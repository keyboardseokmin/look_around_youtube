import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:look_around_youtube/injection_container.dart';
import '../youtube_data.dart';

class YoutubeRestApi {
  final Dio _dio;

  YoutubeRestApi() : _dio = getIt<Dio>();

  Future<Response> _fetchSubscriptions() {
    return _dio.get('https://www.googleapis.com/youtube/v3/subscriptions'
        '?part=id,snippet,contentDetails'
        '&mine=true'
        '&maxResults=50'
    );
  }

  Future<Response> _fetchNewVideos(String channelId, int newVideoCount) {
    return _dio.get('https://www.googleapis.com/youtube/v3/search'
        '?part=id,snippet'
        '&channelId=$channelId'
        '&maxResults=$newVideoCount'
        '&order=date'
        '&type=video'
    );
  }

  Future<List<YoutubeChannelData>> getSubscriptions() async {
    try {
      final response = await _fetchSubscriptions();

      if (response.statusCode == ResponseCodeYoutube.success.intValue) {
        final channels = response.data['items'];
        final channelsData = <YoutubeChannelData>[];
        for (final channel in channels) {
          try {
            channelsData.add(
                YoutubeChannelData(
                    channel['id'],
                    channel['snippet']['resourceId']['channelId'],
                    channel['snippet']['title'],
                    channel['contentDetails']['newItemCount']
                )
            );
          } catch(e) {
            debugPrint(e.toString());
          }
        }
        return channelsData;
      } else {
        return throw Exception();
      }
    } catch(e) {
      return throw Exception();
    }
  }

  Future<List<YoutubeVideoData>> getNewVideos(String channelId, int newVideoCount) async {
    try {
      final response = await _fetchNewVideos(channelId, newVideoCount);

      if (response.statusCode == ResponseCodeYoutube.success.intValue) {
        final videos = response.data['items'];
        final videosData = <YoutubeVideoData>[];
        for (final video in videos) {
          try {
            videosData.add(
                YoutubeVideoData(
                    video['id']['videoId'],
                    video['snippet']['publishedAt'],
                    video['snippet']['title']
                )
            );
          } catch(e) {
            debugPrint(e.toString());
          }
        }
        return videosData;
      } else {
        return throw Exception();
      }
    } catch(e) {
      return throw Exception();
    }
  }
}

enum ResponseCodeYoutube {
  success(200),
  tokenFired(401),
  permissionDenied(403);

  final int intValue;
  const ResponseCodeYoutube(this.intValue);
}