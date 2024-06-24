import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TextFieldCustom extends StatefulWidget {
  final String? title;
  final String? label;
  final Widget? icon;
  final bool? required;
  final bool? enable;
  final int? maxLines;
  final bool? readOnly;
  final bool? isPassword;
  final TextEditingController? controller;
  final String? hint;
  final String? textError;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;
  final Function()? onTap;
  final Function(String value)? onChange;
  final Function(String? value)? onEditingComplete;
  final TextInputType? inputType;
  final double? height;
  final double? width;

  const TextFieldCustom({super.key,
    this.title,
    this.label,
    this.icon,
    this.required,
    this.enable,
    this.maxLines,
    this.readOnly,
    this.onTap,
    this.onChange,
    this.onEditingComplete,
    this.controller,
    this.isPassword,
    this.hint,
    this.inputType,
    this.borderColor,
    this.textError,
    this.margin,
    this.height,
    this.width,
  });

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  bool isShowPass = false;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.grey.shade600, fontSize: (widget.height ?? 48) * 0.5);
    Color borderColor = widget.enable != false ? (widget.borderColor ?? Colors.black) : Colors.grey;
    Color borderErrorColor = widget.enable != false ? Colors.red : Colors.grey;

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(top: 12,right: 16,left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.title != null)
          Row(
            children: [
              if(widget.required == true)
                const Text('*',style: TextStyle(color: Colors.red),),
              Expanded(child: Text(widget.title!, maxLines: 1,style: const TextStyle(fontWeight: FontWeight.w500),)),
            ],
          ),
          if(widget.title != null)
          const SizedBox(height: 6,),
          SizedBox(
            height: widget.height,
            width: widget.width,
            child: TextField(
              keyboardType: widget.inputType,
              controller: widget.controller,
              maxLines: widget.maxLines ?? 1,
              readOnly: widget.enable == false ? true : (widget.readOnly ?? false),
              onTap: widget.onTap,
              obscureText: widget.isPassword == true ? !isShowPass : false,
              onChanged: widget.onChange,
              style: textStyle,
              onEditingComplete: (){
                if(widget.onEditingComplete == null) return;
                widget.onEditingComplete!(widget.controller?.text);
              },
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                hintStyle: textStyle.copyWith(color: Colors.grey, fontWeight: FontWeight.w400),
                labelStyle: textStyle.copyWith(color: Colors.grey, fontWeight: FontWeight.w400),
                filled: true,
                suffixIconColor: Colors.grey,
                fillColor: widget.enable != false ? Colors.white : Colors.grey.shade200,
                errorText: widget.textError,
                suffixIcon: widget.isPassword == true ? IconButton(
                  onPressed: ()  {
                    setState(() {
                      isShowPass = !isShowPass;
                    });
                  },
                  icon: Icon(
                    isShowPass ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ) : widget.icon,
                suffixIconConstraints: BoxConstraints.tight(const Size(30, 30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)
                ),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderErrorColor)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
