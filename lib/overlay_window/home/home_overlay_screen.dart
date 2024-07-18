import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../data/provider/home_provider.dart';
import '../../screen/home/widget/item_room.dart';
import '../../screen/room_chat/room_chat_screen.dart';

class HomeOverlayScreen extends StatefulWidget {
  const HomeOverlayScreen({super.key});

  @override
  State<HomeOverlayScreen> createState() => _HomeOverlayScreenState();
}

class _HomeOverlayScreenState extends State<HomeOverlayScreen> {

  late HomeProvider homeProvider = context.read<HomeProvider>();
  Room? currentRoom;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )
      ),
      margin: const EdgeInsetsDirectional.all(10),
      child: currentRoom != null
        ? RoomChatScreen(
          room: currentRoom!,
          onBack: (){
            currentRoom = null;
            setState(() {});
          },
        )
        : Scaffold(
        appBar: AppBar(
          title: const Text("All chats",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500
            ),
          ),
          leading: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.all(Radius.circular(100))
            ),
            margin: const EdgeInsetsDirectional.all(10),
            child: Image.network(
              homeProvider.profile?.getAvatarUrl(homeProvider.client) ?? "",
              errorBuilder: (_, __, ___){
                return Text(homeProvider.profile?.getFirstCharacterDisplayName ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
        ),
        body: Consumer<HomeProvider>(
          builder: (context, _, child) {
            return ListView.separated(
                itemCount: homeProvider.rooms.length,
                itemBuilder: (context, index){
                  var itemRoom = homeProvider.rooms[index];
                  return ItemRoom(
                    room: itemRoom,
                    onTap: () async{
                      if (itemRoom.membership != Membership.join) {
                        await itemRoom.join();
                      }
                      currentRoom = itemRoom;
                      setState(() {});
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10,)
            );
          },
        ),
      ),
    );
  }
}
