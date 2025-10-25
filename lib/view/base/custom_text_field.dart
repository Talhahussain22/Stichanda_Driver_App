import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  CustomTextField({super.key, required this.hintText,required this.controller,this.keyboardType=TextInputType.text,this.obscureText=false, this.validator, this.prefixIcon});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isvisible=true;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      child:TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText ? isvisible : false,
        validator: widget.validator,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          filled: true,
          fillColor: Colors.grey.shade200,
          hintStyle: TextStyle(color: Colors.black38),
          hintText: widget.hintText,
          suffixIcon: widget.obscureText?(IconButton(
            icon: Icon(
              isvisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black38,
            ),
            onPressed: toggleVisibility,
          )):null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ) ,);
  }

  void toggleVisibility(){

    setState(() {
      isvisible=!isvisible;
    });

  }
}
