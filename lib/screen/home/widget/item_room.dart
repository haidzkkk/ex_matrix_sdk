
import 'package:ex_sdk_matrix/screen/widget/avatar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../../data/provider/home_provider.dart';
import '../../../ultis/date_converter.dart';
import '../../room_chat/room_chat_screen.dart';

class ItemRoom extends StatefulWidget {
  const ItemRoom({super.key, required this.room, this.onTap});
  final Room room;
  final Function? onTap;

  @override
  State<ItemRoom> createState() => _ItemRoomState();
}

class _ItemRoomState extends State<ItemRoom> {


  late HomeProvider authProvider = context.read<HomeProvider>();

  void _join() async{
    await authProvider.selectRoom(widget.room);
    Navigator.push(context,
      MaterialPageRoute(
        builder: (_) => RoomChatScreen(room: widget.room),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? url = widget.room.avatar?.getThumbnail(widget.room.client, width: 56, height: 56,).toString();

    return GestureDetector(
      onTap: (){
        if(widget.onTap != null){
          widget.onTap!();
        }else{
           _join();
        }
      },
      child: Container(
        color: Colors.white,
        height: 60,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(width: 10,),
            AvatarWidget(
              size: 40,
              avatarUrl: url ?? "",
              displayName: widget.room.getLocalizedDisplayname(),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.room.getLocalizedDisplayname(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16),),
                  Text(widget.room.lastEvent?.body ?? 'No messages', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            if(widget.room.notificationCount > 0)
              ...[
                const SizedBox(width: 5,),
                Badge(label: Text(widget.room.notificationCount.toString()),),
                const SizedBox(width: 5,),
              ],
            Text(DateConverter.dateTimeToSinceEpochHourString(widget.room.lastEvent?.originServerTs), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
            const SizedBox(width: 10,),
          ],
         ),
      ),
    );
  }
}
