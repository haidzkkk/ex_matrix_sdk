
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class WidgetOk extends StatefulWidget {
  const WidgetOk({super.key});

  @override
  State<WidgetOk> createState() => _WidgetOkState();
}

class _WidgetOkState extends State<WidgetOk> {
  late Client client;

  @override
  void initState() {

    client = Provider.of<Client>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            GestureDetector(
                onTap: () async{
                  print("Cũng được");
                  Navigator.pop(context);
                },
                child: const Text("Cũng được")
            ),
            GestureDetector(
                onTap: () async{
                  print("Nhỏ");
                },
                child: const Text("Nhỏ")
            ),
            const TextField(),
          ],
        ),
      ),
    );
  }
}
