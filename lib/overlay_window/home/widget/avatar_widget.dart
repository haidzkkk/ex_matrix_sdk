
import 'package:ex_sdk_matrix/data/provider/home_provider.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvatarWidget extends StatefulWidget {
  const AvatarWidget({super.key});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  late HomeProvider homeProvider = context.read<HomeProvider>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<HomeProvider>(
            builder: (context, _, child) {
              String avatarUrl = homeProvider.profile?.getAvatarUrl(homeProvider.client) ?? "";
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: avatarUrl.isEmpty
                  ? null
                  : Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.all(Radius.circular(100))
                    ),
                    margin: const EdgeInsetsDirectional.all(5),
                    child: Image.network(
                      homeProvider.profile?.getAvatarUrl(homeProvider.client) ?? "",
                      errorBuilder: (_, __, ___){
                        return Text(homeProvider.profile?.getFirstCharacterDisplayName ?? "",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
              );
          }
        ),
        Builder(builder: (context){
          int totalBadgets = 0;
          for (var room in homeProvider.client.rooms) {
            totalBadgets += room.notificationCount;
          }
          if(totalBadgets <= 0) return const SizedBox();
          return Positioned(
              right: 5,
              top: 5,
              child: Badge(
                label: Text(totalBadgets.toString()),
              )
          );
        })
      ],
    );
  }
}
