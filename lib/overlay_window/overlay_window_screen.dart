import 'package:ex_sdk_matrix/data/provider/auth_provider.dart';
import 'package:ex_sdk_matrix/overlay_window/home/widget/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/provider/home_provider.dart';
import 'home/home_overlay_screen.dart';

class OverlayWindowScreen extends StatefulWidget {
  const OverlayWindowScreen({super.key});

  @override
  State<OverlayWindowScreen> createState() => _OverlayWindowScreenState();
}

class _OverlayWindowScreenState extends State<OverlayWindowScreen> {

  bool isExpanded = false;

  late AuthProvider authProvider = context.read<AuthProvider>();
  late HomeProvider homeProvider = context.read<HomeProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!authProvider.client.isLogged()){
        print("CHưa login");
        authProvider.loginLocalData()
          .then((value){
              setState(() {});
          }).catchError((onError){

        });
      }else{
        print("Đã login");
        homeProvider.getCurrentUser();
        homeProvider.onSyncRoomChat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isExpanded = MediaQuery.of(context).size.width > 100;
    return Scaffold(
      backgroundColor: isExpanded ? Colors.black.withOpacity(0.5) : Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AvatarWidget(),
          if(isExpanded)
            const Expanded(child: HomeOverlayScreen())
        ],
      ),
    );
  }
}
