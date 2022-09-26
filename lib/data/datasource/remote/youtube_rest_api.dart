import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:look_around_youtube/injection_container.dart';
import '../youtube_channel_data.dart';

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

  Future getSubscriptions() async {
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
}

enum ResponseCodeYoutube {
  success(200),
  tokenFired(401),
  permissionDenied(403);

  final int intValue;
  const ResponseCodeYoutube(this.intValue);
}