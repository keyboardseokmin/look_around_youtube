import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_navigation/misc/navigation_helpers.dart';
import 'package:scroll_navigation/navigation/title_scroll_navigation.dart';

import '../../provider/providers.dart';

class OptionScreen extends ConsumerWidget {
  const OptionScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    return TitleScrollNavigation(
      identiferStyle: const NavigationIdentiferStyle(
        color: Colors.black87
      ),
      barStyle: TitleNavigationBarStyle(
        activeColor: Colors.black87,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),
        padding: EdgeInsets.only(top: 30, bottom: 10, left: 20, right: screenSize.width),
        spaceBetween: 14,
      ),
      titles: const [
        "내 정보",
        "구독",
        "설정",
      ],
      pages: [
        _buildMyPage(ref),
        Container(color: Colors.greenAccent),
        Container(color: Colors.brown)
      ]
    );
  }

  Widget _buildMyPage(WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 20,
            ),
            ref.watch(userProvider).photo == "" ?
            ClipOval(
              child: Container(
                width: 50,
                height: 50,
                color: Colors.white70,
              ),
            ) :
            ClipOval(
              child: CachedNetworkImage(
                width: 50,
                height: 50,
                imageUrl: ref.read(userProvider).photo,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ],
        ),
      ]
    );
  }
}
