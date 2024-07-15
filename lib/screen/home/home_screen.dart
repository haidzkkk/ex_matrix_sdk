
import 'package:ex_sdk_matrix/data/provider/home_provider.dart';
import 'package:ex_sdk_matrix/screen/home/widget/item_room.dart';
import 'package:ex_sdk_matrix/ulti/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../ulti/flutter_overlay.dart';
import '../auth/login_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  late HomeProvider homeProvider = context.read<HomeProvider>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if(!(await FlutterOverlay.hasPermission())){
        showAlterDialog(
          title: "Bong bóng chat",
          content: "Bạn có muốn cho phép chạy dưới nền",
          accept: (){
            FlutterOverlay.requestOverlayPermission();
          },
          cancel: (){

          }
        );
      }
    });
    homeProvider.getCurrentUser();
    homeProvider.onSyncRoomChat();
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
      // client.backgroundSync = true;
      FlutterOverlay.closeOverlay();
    } else if (state == AppLifecycleState.paused) {
      // client.backgroundSync = false;
      FlutterOverlay.showOverlay("alo", "123");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
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
                  backgroundColor: Colors.white,
                  collapsedHeight: 60,
                  expandedHeight: 120,
                  leading: Consumer<HomeProvider>(
                    builder: (context, _, child) {
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
                          homeProvider.profile?.getAvatarUrl(homeProvider.client) ?? "",
                          errorBuilder: (_, __, ___){
                            return Text(homeProvider.profile?.getFirstCharacterDisplayName ?? "",
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
                      onTap: (){
                        Navigator.push(context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const SearchScreen(),
                            transitionDuration: const Duration(milliseconds: 200),
                            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                          ),
                        );
                      },
                      child: const Padding(
                          padding: EdgeInsetsDirectional.all(5),
                          child: Icon(Icons.search, size: 30,)
                      ),
                    ),
                    GestureDetector(
                      onTap: showBottomSheet,
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
        body: Consumer<HomeProvider>(
            builder: (context, _, child) {
              return ListView.separated(
                  itemCount: homeProvider.rooms.length,
                  itemBuilder: (context, index){
                    return ItemRoom(
                      room: homeProvider.rooms[index],
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 10,)
              );
          },
        ),
      ),
    );
  }

  void showAlterDialog({
    required String title,
    required String content,
    Function? accept,
    Function? cancel,
}) {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if(cancel != null)
            GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                  cancel();
                },
                child: const Text("Không")
            ),
          const SizedBox(width: 10,),
          if(accept != null)
            GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                   accept();
                },
                child: const Text("Có")
            ),
        ],
      );
    });}

  showBottomSheet(){
    showModalBottomSheet(
        context: context,
        builder: (context){
      return Container(
        decoration: const BoxDecoration(),
        padding: const EdgeInsetsDirectional.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){},
              child: const Row(
                children: [
                  Icon(Icons.settings_suggest_outlined),
                  SizedBox(width: 10,),
                  Text("Cài đặt")
                ],
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async{
                Navigator.pop(context);
                if(!(await FlutterOverlay.hasPermission())){
                  showAlterDialog(
                    title: "Bong bóng chat",
                    content: "Bạn có muốn cho phép chạy dưới nền",
                    accept: (){
                      FlutterOverlay.requestOverlayPermission();
                    },
                    cancel: (){

                    }
                  );
                }else{
                  showAlterDialog(
                    title: "Bong bóng chat",
                    content: "Bong bóng chat đã chạy dưới nền bạn có muốn tắt?",
                    accept: (){
                      FlutterOverlay.requestOverlayPermission();
                    },
                    cancel: (){

                    }
                  );
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.bubble_chart_outlined),
                  SizedBox(width: 10,),
                  Text("Bong bóng chat")
                ],
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                Navigator.pop(context);
                _logout();
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red,),
                  SizedBox(width: 10,),
                  Text("Đăng xuất", style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _logout() async {
    showAlterDialog(
      title: "Đăng xuất",
      content: "Bạn có chắc muốn đăng xuất tài khoản không?",
      accept: ()async{
        await homeProvider.client.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      },
      cancel: (){}
    );
  }
}
