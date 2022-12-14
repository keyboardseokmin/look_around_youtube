import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:look_around_youtube/data/datasource/local/subscribe_data.dart';
import 'package:look_around_youtube/data/datasource/local/subscribe_data_wrapper.dart';

import '../../../provider/providers.dart';

class SubscribeDataSource {
  static const boxName = 'SubscribesBox';
  static const valueName = 'SubscribeList';
  final Ref ref;
  static late final Box _box;

  SubscribeDataSource(this.ref);

  static init() async {
    _box = await Hive.openBox(boxName);
  }

  Future<void> put(List<String> value) async {
    final local = _box.get(valueName, defaultValue: <SubscribeData>[]);
    final converted = List<SubscribeData>.from(local);

    if (converted.isEmpty) {
      // 저장된 구독리스트가 없을때
      final list = <SubscribeData>[];
      for (var name in value) {
        list.add(SubscribeData(name: name, check: false));
      }
      return await _box.put(valueName, list);
    } else {
      // 저장된 구독리스트가 있을때
      final names = converted.map((e) => e.name);
      final notIncluded = value.where((element) => !names.contains(element));

      for (String name in notIncluded) {
        converted.add(SubscribeData(name: name, check: false));
      }
      return await _box.put(valueName, converted);
    }
  }

  Future<void> putData(List<SubscribeDataWrapper> value) async {
    final list = List<SubscribeData>.from(value.map((e) => SubscribeData(name: e.name, check: e.check)));
    return await _box.put(valueName, list);
  }

  Future<void> putAndUpdate(List<String> value) async {
    final local = _box.get(valueName, defaultValue: <SubscribeData>[]);
    final converted = List<SubscribeData>.from(local);

    if (converted.isEmpty) {
      // 저장된 구독리스트가 없을때
      final hiveList = value.map((e) => SubscribeData(name: e, check: false));
      final providerList = value.map((e) => SubscribeDataWrapper(key: GlobalKey(), name: e, check: false));
      ref.read(subscribeList.notifier).update((state) => state = List<SubscribeDataWrapper>.from(providerList));
      return await _box.put(valueName, hiveList);
    } else {
      // 저장된 구독리스트가 있을때
      final names = converted.map((e) => e.name);
      final notIncluded = value.where((element) => !names.contains(element));

      for (String name in notIncluded) {
        converted.add(SubscribeData(name: name, check: false));
      }
      final providerList = converted.map((e) => SubscribeDataWrapper(key: GlobalKey(), name: e.name, check: e.check));
      ref.read(subscribeList.notifier).update((state) => state = List<SubscribeDataWrapper>.from(providerList));
      return await _box.put(valueName, converted);
    }
  }

  void update(int index, bool value) {
    final list = ref.read(subscribeList);
    list[index].check = value;
    ref.read(subscribeList.notifier).update((state) => list);
    putData(list);
  }

  void read() {
    final temp = List<SubscribeData>.from(_box.get(valueName, defaultValue: <SubscribeData>[]));
    final result = List<SubscribeDataWrapper>.from(temp.map((e) => SubscribeDataWrapper(key: GlobalKey(), name: e.name, check: e.check)));
    ref.read(subscribeList.notifier).update((state) => state = result);
  }
}