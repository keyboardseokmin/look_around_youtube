import 'package:flutter/cupertino.dart';

class YoutubeVideoData {
  late GlobalKey key;
  late String title;
  late String channel;
  late String publishedAt;
  late String videoUrl;

  YoutubeVideoData({
    required this.key,
    required this.title,
    required this.channel,
    required this.publishedAt,
    required this.videoUrl
  });
}