
import 'dart:isolate';
import 'dart:ui';

import 'package:ex_sdk_matrix/my_app/room_chat/widget/text_field_custom.dart';
import 'package:ex_sdk_matrix/ulti/flutter_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomChatWidget extends StatefulWidget {
  const BottomChatWidget({super.key, required this.room});
  final Room room;

  @override
  State<BottomChatWidget> createState() => _BottomChatWidgetState();
}

class _BottomChatWidgetState extends State<BottomChatWidget> with TickerProviderStateMixin{

  TextEditingController messageTextCtrl = TextEditingController();
  late AnimationController animationOptionCtrl;
  late Animation<double> animationOption;

  RxBool isShowOption = false.obs;
  RxBool isSend = false.obs;

  void _send() {
    widget.room.sendTextEvent(messageTextCtrl.text.trim());
    messageTextCtrl.clear();
  }

  Future<void> _gallery(ImageSource source) async {
    if(source == ImageSource.camera && await Permission.camera.request().isDenied){
      return;
    }

    final XFile? image = await ImagePicker().pickImage(source: source);
    if(image == null) return;

    var bytes = await image.readAsBytes();
    MatrixFile matrixFile = MatrixFile(bytes: bytes, name: DateTime.now().millisecondsSinceEpoch.toString());
    widget.room.sendFileEvent(matrixFile,);
  }

  @override
  void initState() {
    animationOptionCtrl = AnimationController(
      vsync: this,
      duration: 200.milliseconds,
    );
    animationOption = Tween(begin: 0.0, end: 3.14 / 4 * 3).animate(animationOptionCtrl);

    messageTextCtrl.addListener(() {
      widget.room.setTyping(messageTextCtrl.text.isNotEmpty);
      isSend.value = messageTextCtrl.text.isNotEmpty;
    });

    super.initState();
  }

  @override
  void dispose() {
    messageTextCtrl.dispose();
    animationOptionCtrl.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {

    List<Widget> itemOptions = [
      Expanded(
        child: GestureDetector(
            onTap: (){
              _gallery(ImageSource.gallery);
            },
            child: const Icon(Icons.image, size: 25,)
        ),
      ),
      Expanded(
        child: GestureDetector(
            onTap: (){
              _gallery(ImageSource.camera);
            },
            child: const Icon(Icons.camera_alt, size: 25,)
        ),
      ),
      Expanded(
        child: GestureDetector(
            onTap: () async{
              FlutterOverlay.showOverlay("alo", "123");
            },
            child: const Icon(Icons.location_on_rounded, size: 25,)
        ),
      ),
      Expanded(
        child: GestureDetector(
            onTap: (){
              FlutterOverlay.closeOverlay();
            },
            child: const Icon(Icons.bar_chart, size: 25,)
        ),
      ),
      Expanded(
        child: GestureDetector(
            onTap: (){
            },
            child: const Icon(Icons.people, size: 25,)
        ),
      ),
      Expanded(
        child: GestureDetector(
            onTap: (){
            },
            child: const Icon(Icons.file_present_rounded, size: 25,)
        ),
      ),
    ];

    return  SizedBox(
      height: 40,
      width: double.infinity,
      child: Row(
        children: [
          Obx(() => AnimatedContainer(
            duration: 200.milliseconds,
            width: 20 + ((isShowOption.value ? itemOptions.length + 5 : 1) * 20),
            child: Container(
              margin: const EdgeInsetsDirectional.all(5),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadiusDirectional.all(Radius.circular(100))
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      isShowOption.value = !isShowOption.value;
                      if (isShowOption.value) {
                        animationOptionCtrl.forward();
                      } else {
                        animationOptionCtrl.reverse();
                      }
                    },
                    child: AnimatedBuilder(
                        animation: animationOptionCtrl,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: animationOption.value,
                            child: const Icon(Icons.add, size: 20,),
                          );
                        }
                    ),
                  ),
                  if(isShowOption.value)
                    ...itemOptions
                ],
              ),
            ),
          )),
          Expanded(
              child: TextFieldCustom(
                onTap: (){
                  isShowOption.value = false;
                },
                borderColor: Colors.grey,
                margin: const EdgeInsets.symmetric(vertical: 5),
                height: 30,
                hint: "Message...",
                controller: messageTextCtrl,
                onEditingComplete: (s){
                  if(s == null || s.isEmpty) return;
                  _send();
                },
                icon: const Icon(Icons.emoji_emotions_rounded, size: 20,),
              )
          ),
          Obx(() => isSend.value
              ? Container(
            margin: const EdgeInsetsDirectional.all(5),
            padding: const EdgeInsetsDirectional.all(5),
            decoration: const BoxDecoration(
                borderRadius: BorderRadiusDirectional.all(Radius.circular(100))
            ),
            child: GestureDetector(
                onTap: _send,
                child: const Icon(Icons.send, size: 20, color: Colors.teal,)
            ),
          )
              : Container(
            margin: const EdgeInsetsDirectional.all(5),
            padding: const EdgeInsetsDirectional.all(5),
            decoration: const BoxDecoration(
                borderRadius: BorderRadiusDirectional.all(Radius.circular(100))
            ),
            child: GestureDetector(
                child: const Icon(Icons.mic, size: 20,)
            ),
          )),
        ],
      ),
    );
  }

}
