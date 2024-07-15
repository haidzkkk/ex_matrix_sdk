
import 'package:ex_sdk_matrix/screen/search/widget/search_room_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import '../room_chat/room_chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final Client client;

  ScrollController scrollCtrl = ScrollController();
  TextEditingController searchTextCtrl = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  SearchUserDirectoryResponse? data;
  bool isLoading = false;
  bool isLoadingJoin = false;
  int pageIndex = 1;

  @override
  void initState() {
    client = Provider.of<Client>(context, listen: false);
    searchFocusNode.requestFocus();
    scrollCtrl.addListener((){
      if((data?.results.length ?? 0) > 0
        && scrollCtrl.offset == scrollCtrl.position.maxScrollExtent
      ){
        pageIndex++;
        _search();
      }
    });

    super.initState();
  }

  _search() async{
    isLoading = true;
    setState(() {});
    try{
      data = await client.searchUserDirectory(searchTextCtrl.text, limit: pageIndex * 10,);
    }catch(e){
      data = null;
    }
    isLoading = false;
    setState(() {});
  }

  void _join(String id) async{
    if(isLoadingJoin == true) return;
    isLoadingJoin = true;
    setState(() {});
    try{
      var roomId = await client.joinRoomById(id);
      Room? room = client.getRoomById(roomId);
      if(room == null) return;

      Navigator.push(context,
        MaterialPageRoute(
          builder: (_) => RoomChatScreen(room: room),
        ),
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    isLoadingJoin = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    scrollCtrl.dispose();
    searchTextCtrl.dispose();
    searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leadingWidth: 40,
        title: TextField(
          focusNode: searchFocusNode,
          controller: searchTextCtrl,
          cursorColor: Colors.teal,
          decoration: InputDecoration(
            suffixIcon: searchTextCtrl.text.isEmpty ? null : IconButton(
                onPressed: (){
                  searchTextCtrl.text = "";
                  pageIndex = 1;
                  _search();
                },
                icon: const Icon(Icons.clear)
            ),
            icon: const Icon(Icons.search),
            hintText: "Name or ID (#example:matrix.org)",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          onChanged: (value){
            pageIndex = 1;
            _search();
          },
        ),
        actions: [
          IconButton(
            onPressed: (){

            },
            icon: const Icon(Icons.more_vert)
          )
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.teal,
            onRefresh: () async{
              await _search();
            },
            child: ListView(
              controller: scrollCtrl,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Text("Can't find what you are looking for?"),
                      SizedBox(height: 15,),
                      Text("CREATE NEW ROOM", style: TextStyle(letterSpacing: 1.5 ,color: Colors.teal, fontWeight: FontWeight.w600,),),
                    ],
                  ),
                ),
                if((data?.results.length ?? 0) > 0)
                  RichText(
                    text: TextSpan(children: [
                      const TextSpan(text: "   ROOMS  ", style: TextStyle(color: Colors.black)),
                      TextSpan(text: "${data?.results.length}", style: const TextStyle(color: Colors.grey)),
                    ]),
                  ),
                ... data?.results.map((e) => SearchRoomItem(
                  room: e,
                  onTap: (){
                    _join(e.userId);
                  },
                )) ?? [],
                if(isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.teal,)),
              ],
            ),
          ),
          if(isLoadingJoin)
          Container(
            color: Colors.white.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator(color: Colors.teal,)
          ),
          )
        ],
      )
    );
  }
}
