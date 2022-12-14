import 'package:hive/hive.dart';

part 'subscribe_data.g.dart';

@HiveType(typeId: 0)
class SubscribeData {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final bool check;

  SubscribeData({required this.name, required this.check});
}