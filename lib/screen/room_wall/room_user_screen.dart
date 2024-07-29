
import 'package:ex_sdk_matrix/screen/room_wall/room_wall_screen.dart';
import 'package:ex_sdk_matrix/screen/room_wall/widget/item_member.dart';
import 'package:ex_sdk_matrix/screen/widget/avatar_widget.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../data/provider/room_provider.dart';
import '../../ultis/color_resources.dart';
import '../../ultis/style.dart';
import '../widget/text_search_custom.dart';

class RoomUserScreen extends StatefulWidget {
  const RoomUserScreen({super.key});

  @override
  State<RoomUserScreen> createState() => _RoomUserScreenState();
}

class _RoomUserScreenState extends State<RoomUserScreen> {

  late RoomWallStateProvider roomDetailState;
  late RoomProvider roomProvider = context.read<RoomProvider>();

  ScrollController scrollCtrl = ScrollController();
  TextEditingController searchTextCtrl = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  String textSearch = "";

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: ColorResources.backgroundColor100,
              padding: const EdgeInsetsDirectional.only(start: 10, end: 10, bottom: 10),
              child: TextSearchCustom(
                searchFocusNode: searchFocusNode,
                searchTextCtrl: searchTextCtrl,
                hint: "Filter room members",
                onChange: (value){
                  textSearch = value ?? "";
                  setState(() {});
                },
              ),
            ),
            Selector<RoomProvider, List<User>>(
                selector: (buildContext , roomProvider ) => roomProvider.members,
                builder: (BuildContext context, members, Widget? child) {
                  List<User> admins = members.where(
                          (element) => element.isAdmin && (textSearch.isNotEmpty ? element.displayName?.contains(textSearch) == true : true)).toList();
                  List<User> users = members.where(
                          (element) => !element.isAdmin && (textSearch.isNotEmpty ? element.displayName?.contains(textSearch) == true : true)).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: ColorResources.backgroundColor50,
                      padding: const EdgeInsetsDirectional.all(10),
                      child: const Text("Admins", style: Style.title)
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: admins.length,
                      itemBuilder: (context, index) => MemberItem(user: admins[index],),
                      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1,),
                    ),
                    Container(
                      width: double.infinity,
                      color: ColorResources.backgroundColor50,
                      padding: const EdgeInsetsDirectional.all(10),
                      child: const Text("Users", style: Style.title)
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: users.length,
                      itemBuilder: (context, index) => MemberItem(user: users[index],),
                      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1,),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
