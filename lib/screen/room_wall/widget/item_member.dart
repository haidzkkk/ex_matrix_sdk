
import 'package:ex_sdk_matrix/screen/widget/avatar_widget.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../../data/provider/room_provider.dart';

class MemberItem extends StatefulWidget {
  const MemberItem({super.key, required this.user});

  final User user;

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  late RoomProvider roomProvider = context.read<RoomProvider>();

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsetsDirectional.all(10),
      child: Row(
        children: [
          AvatarWidget(
            size: 30,
            avatarUrl: widget.user.getAvatarUrl(client: roomProvider.client),
            displayName: widget.user.displayName ?? "",
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.displayName ?? ""),
                Text(widget.user.senderId ?? ""),
              ],
            ),
          ),
          const SizedBox(width: 10,),
          Text(widget.user.isAdmin ? "Admin" : "Member"),
        ],
      ),
    );
  }
}
