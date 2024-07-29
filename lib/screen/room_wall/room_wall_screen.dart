
import 'package:ex_sdk_matrix/screen/room_wall/room_storage_screen.dart';
import 'package:ex_sdk_matrix/screen/room_wall/room_user_screen.dart';
import 'package:ex_sdk_matrix/screen/room_wall/widget/app_bar_widget.dart';
import 'package:ex_sdk_matrix/ultis/color_resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../data/provider/room_provider.dart';
import '../../ultis/style.dart';

class RoomWallStateProvider extends ChangeNotifier{
  double appBarCollapseHeight = 80;
  double appBarExpandHeight = 180;
  bool isExpandedAppbar = true;
  bool isCommunity = false;

  onCollapseAppbar(double height){
    Future((){
      if(height <= appBarCollapseHeight && isExpandedAppbar == true){
        isExpandedAppbar = false;
        notifyListeners();
      }else if(height >= 100 && isExpandedAppbar == false){
        isExpandedAppbar = true;
        notifyListeners();
      }
    });
  }

  checkCommunity(Room? room){
    isCommunity = room?.canonicalAlias.isNotEmpty == true;
    if(isCommunity){
      appBarExpandHeight += 20;
    }
  }
}

class RoomWallScreen extends StatefulWidget {
  const RoomWallScreen({super.key});

  @override
  State<RoomWallScreen> createState() => _RoomWallScreenState();
}

class _RoomWallScreenState extends State<RoomWallScreen> {

  late RoomWallStateProvider roomDetailState;
  late RoomProvider roomProvider = context.read<RoomProvider>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomWallStateProvider(),
      child: Builder(
        builder: (context) {
          roomDetailState = context.read<RoomWallStateProvider>();
          return Scaffold(
            backgroundColor: ColorResources.backgroundColor,
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  const AppBarWidget()
                ];
              },
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: ColorResources.backgroundColor50,
                      padding: const EdgeInsetsDirectional.all(10),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Security", style: Style.title,),
                          SizedBox(height: 15,),
                          Text("Messages here are end-to-end encrypted.", style: Style.contentSmall),
                          SizedBox(height: 10,),
                          Text("Your message are secured with locks and only you and the recippient the enuque keys to unlock them.", style: Style.contentSmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsetsDirectional.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: Text("Never send encrypted messages to unverified sessions in this room.", style: Style.content)),
                          const SizedBox(width: 20,),
                          Selector<RoomProvider, bool>(
                              selector: (buildContext , roomProvider ) => roomProvider.encrypted,
                              builder: (BuildContext context, encrypted, Widget? child) {
                              return Switch(
                                value: encrypted,
                                activeColor: ColorResources.primaryColor,
                                onChanged: (value){
                                  roomProvider.setEncrypted(value);
                                },
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: ColorResources.backgroundColor50,
                      padding: const EdgeInsetsDirectional.all(10),
                      child: const Text("More", style: Style.title),
                    ),
                    const SizedBox(height: 10,),
                    Builder(
                        builder: (context) {
                          var items = [
                            itemFeature(
                                icon: FontAwesomeIcons.gear,
                                label: "Setting",
                                onTap: (){
                                }
                            ),
                            itemFeature(
                                icon: FontAwesomeIcons.solidBell,
                                label: "Notification",
                                onTap: (){
                                }
                            ),
                            Selector<RoomProvider, List<User>>(
                              selector: (buildContext , roomProvider ) => roomProvider.members,
                              builder: (BuildContext context, members, Widget? child) {
                                return itemFeature(
                                    icon: FontAwesomeIcons.users,
                                    label: "${members.length} people",
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomUserScreen()));
                                    }
                                );
                              },
                            ),
                            itemFeature(
                                icon: FontAwesomeIcons.chartColumn,
                                label: "Poll history",
                                onTap: (){
                                }
                            ),
                            itemFeature(
                                icon: FontAwesomeIcons.upload,
                                label: "Uploads",
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomStorageScreen()));
                                }
                            ),
                            itemFeature(
                                icon: FontAwesomeIcons.mobileScreen,
                                label: "Add to home screen",
                                onTap: (){
                                }
                            ),
                            itemFeature(
                                icon: FontAwesomeIcons.doorOpen,
                                label: "Leave",
                                color: Colors.redAccent,
                                onTap: (){
                                }
                            ),
                          ];
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            itemBuilder: (context, index) => items[index],
                            separatorBuilder: (BuildContext context, int index) => const Divider(height: 1,),
                          );
                        }
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      width: double.infinity,
                      color: ColorResources.backgroundColor50,
                      padding: const EdgeInsetsDirectional.all(10),
                      child: const Text("Advanced", style: Style.title),
                    ),
                    const SizedBox(height: 10,),
                    Builder(
                      builder: (context) {
                        var items = [
                          itemAdvanced(
                              label: "Room addresses",
                              content: "See and managed addresses of this room, and tis visibility in the room directory",
                              onTap: (){
                              }
                          ),
                          itemAdvanced(
                              label: "Room addresses",
                              content: "See and managed addresses of this room, and tis visibility in the room directory",
                              onTap: (){
                              }
                          ),
                        ];
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: items.length,
                          itemBuilder: (context, index) => items[index],
                          separatorBuilder: (BuildContext context, int index) => const Divider(height: 1,),
                        );
                      }
                    ),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget itemFeature({
    required IconData icon,
    required String label,
    Color? color,
    required Function() onTap
  }){
    return GestureDetector(
      onTap: (){
        onTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color ?? ColorResources.iconColor, size: 22,),
            const SizedBox(width: 20),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Style.content.copyWith(color: color),),
                  ],
                )
            ),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_right, color: ColorResources.iconColor)
          ],
        ),
      ),
    );
  }

  Widget itemAdvanced({
    required String label,
    required String content,
    required Function() onTap
  }){
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Style.content,),
                  Text(content, style: Style.contentSupperSmall,),
                ],
              )
            ),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_right, color: ColorResources.iconColor)
          ],
        ),
      ),
    );
  }
}
