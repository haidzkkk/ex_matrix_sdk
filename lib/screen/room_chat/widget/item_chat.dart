import 'package:ex_sdk_matrix/screen/widget/avatar_widget.dart';
import 'package:ex_sdk_matrix/screen/widget/image_widget.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../data/model/slide.dart';
import '../../../ultis/date_converter.dart';
import '../../../ultis/utils.dart';

class ItemChatProvider extends ChangeNotifier{
  bool isTabItem = false;

  changeTabItem(){
    isTabItem = !isTabItem;
    notifyListeners();
  }
}

class ItemChat extends StatefulWidget {
  const ItemChat({
    super.key,
    required this.data,
    required this.typeMe,
    required this.latter,
    required this.showInfo,
    required this.showTimer,
  });

  final bool typeMe;
  final bool showInfo;
  final bool latter;
  final bool showTimer;
  final Event data;

  @override
  State<ItemChat> createState() => _ItemChatState();
}

class _ItemChatState extends State<ItemChat> {

  EdgeInsetsGeometry paddingItem = const EdgeInsets.symmetric(horizontal: 7, vertical: 7);
  EdgeInsetsGeometry padding = const EdgeInsets.only(left: 35, right: 7, bottom: 7);

  late ItemChatProvider itemChatProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemChatProvider>(
      create: (BuildContext context) =>  ItemChatProvider(),
      child: Builder(
        builder: (context) {
          itemChatProvider = context.read<ItemChatProvider>();

          return Column(
            crossAxisAlignment: widget.typeMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [

              if(widget.showTimer) timerWidget(),
              if((widget.showTimer || widget.showInfo) && !widget.typeMe) infoWidget(),
              Container(
                  margin: padding,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadiusDirectional.all(Radius.circular(10))
                  ),
                  child: contentWidget()
              ),
              Selector<ItemChatProvider, bool>(
                selector: (context, itemChatProvider) => itemChatProvider.isTabItem,
                builder: (context, isTab, child){
                  if(itemChatProvider.isTabItem
                      || widget.data.status == EventStatus.sending
                      || widget.data.status == EventStatus.error
                  ){

                    return Padding(
                      padding: padding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.data.status.getString(), style: const TextStyle(fontSize: 8),),
                          const SizedBox(width: 5,),
                          Text(DateConverter.dateTimeSinceEpochHourString(widget.data.originServerTs), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400), ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              )

            ],
          );
        }
      ),
    );
  }

  Widget timerWidget(){
    return Padding(
      padding: paddingItem,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Container(
            height: 1,
            color: Colors.grey,
            margin: const EdgeInsets.only(right: 15),
          )),
          Text(DateConverter.dateTimeSinceEpochMonthString(widget.data.originServerTs), style: const TextStyle(color: Colors.grey),),
          Expanded(child: Container(
            height: 1,
            color: Colors.grey,
            margin: const EdgeInsets.only(left: 15),
          )),
        ],
      ),
    );
  }

  Widget infoWidget(){
    return Padding(
      padding: paddingItem,
      child: Row(
        children: [
          AvatarWidget(
            size: 20,
            avatarUrl: widget.data.attachmentMxcUrl.toString(),
            displayName: widget.data.senderFromMemoryOrFallback.displayName ?? "",
          ),
          const SizedBox(width: 7,),
          Text(widget.data.senderFromMemoryOrFallback.displayName ?? "", style: const TextStyle(color: Colors.pinkAccent),),
          const SizedBox(width: 10),
          Text(DateConverter.dateTimeSinceEpochHourString(widget.data.originServerTs), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400), ),
        ],
      ),
    );
  }

  Widget contentWidget(){
    switch(widget.data.type){
      case EventTypes.RoomMember: {
        return typeContentMember();
      }
      case EventTypes.Message: {
        return typeContentMessage();
      }
      // case MessageType.selectAnswer: {
      //   return Text("MessageType.selectAnswer");
      // }
      // case MessageType.callAnswer: {
      //   return Text("MessageType.callAnswer");
      // }
      // case MessageType.callHangup: {
      //   return Text("MessageType.callHangup");
      // }
      // case MessageType.callCandidates: {
      //   return Text("MessageType.callCandidates");
      // }
      // case MessageType.callNegotiate: {
      //   return Text("MessageType.callNegotiate");
      // }
      // case MessageType.callInvite: {
      //   return Text("MessageType.callInvite");
      // }
      // case MessageType.modularWidgets: {
      //   return Text("MessageType.modularWidgets");
      // }
      // case MessageType.encrypted: {
      //   return Text("MessageType.encrypted");
      // }
      // case MessageType.encryption: {
      //   return Text("MessageType.encryption");
      // }
      // case MessageType.name: {
      //   return Text("MessageType.name");
      // }
      // case MessageType.guestAccess: {
      //   return Text("MessageType.guestAccess");
      // }
      // case MessageType.historyVisibility: {
      //   return Text("MessageType.historyVisibility");
      // }
      // case MessageType.joinRules: {
      //   return Text("MessageType.joinRules");
      // }
      // case MessageType.powerLevels: {
      //   return Text("MessageType.powerLevels");
      // }
      // case MessageType.create: {
      //   return Text("MessageType.create");
      // }
    }

    return SizedBox(
        height: 40,
        child: Text(widget.data.type)
    );
  }

  Widget typeContentMessage() {
    switch(widget.data.content['msgtype']){
      case MessageTypes.Text: {
        return Material(
          color: Colors.black.withOpacity(0.1),
          child: GestureDetector(
            onTap: (){
              itemChatProvider.changeTabItem();
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(widget.data.body)),
          ),
        );
      }
      case MessageTypes.Video: {
        String thumb = widget.data.getAttachmentUrl(getThumbnail: true)?.toString() ?? "";
        String url = widget.data.getAttachmentUrl()?.toString() ?? "";

        return GestureDetector(
          onTap: (){
            navigateToSlideWidget(
              context: context,
              medias: [
                SlideMedia(url: url, thumb: thumb, type: SlideType.video),
              ],
            );
          },
          child: Container(
              color: Colors.pink.withOpacity(0.1),
              width: MediaQuery.of(context).size.width * 0.7,
            child: Stack(
                alignment: Alignment.center,
                children: [
                  ImageWidget(
                    url: url,
                    hero: url,
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.play_circle, color: Colors.white,)
                  ),
                ],
              ),
          ),
        );
      }
      case MessageTypes.Image: {
          String? url = widget.data.getAttachmentUrl()?.toString();
          return GestureDetector(
            onTap: (){
              navigateToSlideWidget(
                context: context,
                medias: [
                  SlideMedia(url: url ?? "", type: SlideType.image),
                ],
              );
            },
            child: Container(
              color: Colors.pink.withOpacity(0.1),
              width: MediaQuery.of(context).size.width * 0.7,
              child: ImageWidget(url: url ?? "", hero: url,)
            ),
          );
      }
    }
    return const Text("message default");
   }


  Widget typeContentMember() {
    // switch(widget.data.content?.membership) {
    //   case MessageContentMemberType.invite:{
    //     return Text("${widget.data.sender} đã mời ${widget.data.content?.displayname} vào nhóm");
    //   }
    //   case MessageContentMemberType.join:{
    //     return Text("${widget.data.content?.displayname} đã tham gia phòng");
    //   }
    // }
    return const SizedBox(
        height: 40,
        child: Text("member default")
    );
  }
}
