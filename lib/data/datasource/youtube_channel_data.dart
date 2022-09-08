class YoutubeChannelData {
  late String id;
  late String name;
  late int newItemCount;

  YoutubeChannelData(this.id, this.name, this.newItemCount);

  YoutubeChannelData.fromJson(Map json) {
    id = json['id'];
    name = json['snippet']['title'];
    newItemCount = json['contentDetails']['newItemCount'];
  }
}