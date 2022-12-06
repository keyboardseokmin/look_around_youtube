import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionScreen extends ConsumerWidget {
  const OptionScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "내 정보"),
              Tab(text: "구독"),
              Tab(text: "설정")
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Text('one'),
            Text('two'),
            Text('three'),
          ],
        ),
      ),
    );
  }
}
