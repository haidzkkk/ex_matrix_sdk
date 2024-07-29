
import 'package:ex_sdk_matrix/data/model/slide.dart';
import 'package:ex_sdk_matrix/screen/room_wall/room_wall_screen.dart';
import 'package:ex_sdk_matrix/screen/widget/slide_widget.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/provider/room_provider.dart';
import '../../../ultis/color_resources.dart';
import '../../../ultis/utils.dart';
import '../../widget/avatar_widget.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({super.key});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {

  late RoomWallStateProvider roomDetailState = context.read<RoomWallStateProvider>();
  late RoomProvider roomProvider = context.read<RoomProvider>();

  @override
  void initState() {
    roomDetailState.checkCommunity(roomProvider.room);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      expandedHeight: roomDetailState.appBarExpandHeight,
      pinned: true,
      title: Selector<RoomWallStateProvider, bool>(
          selector: (context , roomDetailStateProvider ) => roomDetailStateProvider.isExpandedAppbar,
          builder: (BuildContext context, isExpandedAppbar, Widget? child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExpandedAppbar
                  ? null
                  : Row(
                children: [
                  if(roomProvider.room != null)
                    AvatarWidget(
                        size: 30,
                        avatarUrl: roomProvider.room!.getAvatarUrl(),
                        displayName: roomProvider.room!.getLocalizedDisplayname(),
                    ),
                  const SizedBox(width: 10,),
                  Expanded(
                      child: Text(roomProvider.room?.getLocalizedDisplayname() ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16
                        ),
                      )
                  ),
                ],
              ),
            );
          }
      ),
      actions: [
        IconButton(
          onPressed: (){
            Share.shareUri(roomProvider.getRoomUri());
          },
          icon: const FaIcon(FontAwesomeIcons.shareNodes, color: ColorResources.primaryColor)
        )
      ],
      flexibleSpace: LayoutBuilder(
          builder: (context, boxConstraints) {
            roomDetailState.onCollapseAppbar(boxConstraints.maxHeight);
            return FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 40,),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if(roomProvider.room != null)
                        AvatarWidget(
                          size: 100,
                          avatarUrl: roomProvider.room!.getAvatarUrl(),
                          displayName: roomProvider.room!.getLocalizedDisplayname(),
                          heroTag: roomProvider.room!.getAvatarUrl(),
                          onTap: (){
                            navigateToSlideWidget(
                              context: context,
                              medias: [
                                SlideMedia(url: roomProvider.room!.getAvatarUrl(), type: SlideType.image),
                              ],
                            );
                          },
                        ),
                      if(roomDetailState.isCommunity)
                        Positioned(
                          bottom: 5,
                          right: 0,
                          child: Container(
                              padding: const EdgeInsetsDirectional.all(1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.earthAmericas,
                                color: Colors.black54,
                                size: 20,
                              )
                          ),
                        )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(!roomDetailState.isCommunity)
                        Container(
                            padding: const EdgeInsetsDirectional.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const FaIcon(
                              Icons.shield_outlined,
                              color: Colors.black54,
                              size: 30,
                            )
                        ),
                      Text(roomProvider.room?.getLocalizedDisplayname() ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                    ],
                  ),
                  Text(roomProvider.room?.canonicalAlias ?? ""),
                ],
              ),
            );
          }
      ),
    );
  }
}
