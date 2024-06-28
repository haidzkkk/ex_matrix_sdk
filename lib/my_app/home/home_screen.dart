
import 'package:ex_sdk_matrix/my_app/home/widget/item_room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../ulti/flutter_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  late final Client client;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    client = Provider.of<Client>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      FlutterOverlay.closeOverlay();
    } else if (state == AppLifecycleState.paused) {
      FlutterOverlay.showOverlay("alo", "123");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag:  'unique_tag_1',
            onPressed: (){
            },
            mini: true,
            backgroundColor: Colors.white,
            child: const Icon(Icons.dashboard_outlined, color: Colors.greenAccent,),
          ),
          const SizedBox(height: 15,),
          FloatingActionButton(
            heroTag:  'unique_tag_2',
            onPressed: (){
            },
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.note_alt_outlined, color: Colors.white),
          ),
        ],
      ),
      body: NestedScrollView(

        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverAppBar(
                  collapsedHeight: 60,
                  expandedHeight: 120,
                  leading: FutureBuilder(
                    future: client.getProfileFromUserId(client.userID ?? ""),
                    builder: (context, snapshot) {
                      return Container(
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
                          snapshot.data?.avatarUrl?.getThumbnail(client, width: 56, height: 56,).toString() ?? "",
                          errorBuilder: (_, __, ___){
                            return Text(snapshot.data?.displayName?.split('').first.toUpperCase() ?? "",
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                            );
                          },
                        ),
                      );
                    }
                  ),
                  surfaceTintColor: Colors.white,
                  shadowColor: Colors.black,
                  pinned: true,
                  floating: true,
                  snap: true,
                  flexibleSpace: const FlexibleSpaceBar(
                      title: Text("All chats",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      background:SizedBox()
                  ),

                  actions: [
                    GestureDetector(
                      onTap: (){},
                      child: const Padding(
                          padding: EdgeInsetsDirectional.all(5),
                          child: Icon(Icons.search, size: 30,)
                      ),
                    ),
                    GestureDetector(
                      onTap: (){},
                      child: const Padding(
                          padding: EdgeInsetsDirectional.all(5),
                          child: Icon(Icons.more_vert, size: 30)
                      ),
                    ),
                  ],
                ),
              ),
            )
          ];
        },
        body: StreamBuilder(
          stream: client.onSync.stream,
          builder: (context, asyncSnapShot){
            return ListView.separated(
                itemCount: client.rooms.length,
                itemBuilder: (context, index){
                  return ItemRoom(
                    room: client.rooms[index],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10,)
            );
          },
        ),
      ),
    );
  }

  void resetDataClient() async{
    await client.clear();
    await client.clearCache();
    client.clearArchivesFromCache();
  }
}
