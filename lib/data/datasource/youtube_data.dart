class YoutubeChannelData {
  late String id;
  late String channelId;
  late String name;
  late int newItemCount;

  YoutubeChannelData(this.id, this.channelId, this.name, this.newItemCount);
}

class YoutubeVideoData {
  late String videoId;
  late String publishedAt;
  late String title;

  YoutubeVideoData(this.videoId, this.publishedAt, this.title);
}