
import 'package:ex_sdk_matrix/screen/room_wall/room_storage_media_screen.dart';
import 'package:ex_sdk_matrix/screen/room_wall/room_wall_screen.dart';
import 'package:ex_sdk_matrix/screen/room_wall/widget/room_storage_file_screen.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/provider/room_provider.dart';
import '../../ultis/color_resources.dart';
import '../widget/avatar_widget.dart';

class RoomStorageScreen extends StatefulWidget {
  const RoomStorageScreen({super.key});

  @override
  State<RoomStorageScreen> createState() => _RoomStorageScreenState();
}

class _RoomStorageScreenState extends State<RoomStorageScreen> {

  late RoomWallStateProvider roomDetailState;
  late RoomProvider roomProvider = context.read<RoomProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            if(roomProvider.room != null)
            // roomProvider.room!.
              AvatarWidget(
                  size: 30,
                  avatarUrl: roomProvider.room!.getAvatarUrl(),
                  displayName: roomProvider.room!.getLocalizedDisplayname()
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
      ),
      body: const DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorPadding: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(vertical: 10),
              indicatorColor: ColorResources.primaryColor,
              labelColor: ColorResources.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                    child: Text("Media", style: TextStyle(letterSpacing: 1.5),)
                ),
                Tab(
                    child: Text("Files", style: TextStyle(letterSpacing: 1.5),)
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RoomStorageMediaScreen(),
                  RoomStorageFileScreen(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
