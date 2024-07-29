import 'package:flutter/material.dart';

class TextSearchCustom extends StatefulWidget {
  const TextSearchCustom({
    super.key,
    this.searchFocusNode,
    required this.searchTextCtrl,
    this.onChange,
    this.hint,
    this.padding,
  });

  final FocusNode? searchFocusNode;
  final TextEditingController searchTextCtrl;
  final Function(String)? onChange;
  final String? hint;
  final EdgeInsetsGeometry? padding;

  @override
  State<TextSearchCustom> createState() => _TextSearchCustomState();
}

class _TextSearchCustomState extends State<TextSearchCustom> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: TextField(
        focusNode: widget.searchFocusNode,
        controller: widget.searchTextCtrl,
        cursorColor: Colors.teal,
        decoration: InputDecoration(
          suffixIcon: widget.searchTextCtrl.text.isEmpty ? null : IconButton(
              onPressed: (){
                widget.searchTextCtrl.text = "";
                if(widget.onChange != null) widget.onChange!("");
              },
              icon: const Icon(Icons.clear)
          ),
          icon: GestureDetector(
              onTap: (){
                if(widget.onChange != null) widget.onChange!(widget.searchTextCtrl.text);
              },
              child: const Icon(Icons.search)
          ),
          hintText: widget.hint ?? "Search...",
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
        ),
        onChanged: (value){
          if(widget.onChange != null) widget.onChange!(value);
        },
      ),
    );
  }
}
