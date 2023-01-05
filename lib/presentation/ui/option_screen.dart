import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_navigation/misc/navigation_helpers.dart';
import 'package:scroll_navigation/navigation/title_scroll_navigation.dart';

import '../../provider/providers.dart';
import '../app_fonts.dart';

class OptionScreen extends ConsumerWidget {
  const OptionScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        TitleScrollNavigation(
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
            _buildSubscribe(ref),
            Container(color: Colors.brown)
          ]
        ),
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black87,
                iconSize: 40,
                onPressed: () {
                  ref.read(isOptionShowed.notifier).update((state) => false);
                },
              ),
            ]
          )
        )
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
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watch(userProvider).id,
                  style: AppFonts.myInfoId,
                ),
                const SizedBox(height: 5),
                Text(
                  ref.watch(userProvider).nickname,
                  style: AppFonts.myInfoName,
                ),
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                ref.read(headlessWebViewProvider).logOut();
              },
              child: const Text('로그아웃', style: AppFonts.myInfoOut),
            ),
            const SizedBox(width: 10),
          ]
        ),
      ]
    );
  }

  Widget _buildSubscribe(WidgetRef ref) {
    ref.read(headlessWebViewUserProvider).getSubscribeList();
    final list = ref.watch(subscribeList);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Scrollbar(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                key: list[index].key,
                onTap: () {
                  ref.read(subscribeDataSource).update(index, !list[index].check);
                },
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    list[index].check ?
                    Text(
                      list[index].name,
                      style: AppFonts.myInfoChannelChecked,
                    ) :
                    Text(
                      list[index].name,
                      style: AppFonts.myInfoChannel,
                    )
                    ,
                    const SizedBox(height: 12)
                  ]
                ),
              );
            }
          ),
        ),
      )
    );
  }
}
