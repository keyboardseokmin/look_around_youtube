import 'package:flutter/cupertino.dart';

class YoutubeVideoData {
  GlobalKey key;
  String title, channel, publishedAt, videoUrl;

  YoutubeVideoData({
    required this.key,
    required this.title,
    required this.channel,
    required this.publishedAt,
    required this.videoUrl
  });
}