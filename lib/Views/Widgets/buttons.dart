import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomFillButton extends StatelessWidget {
  final String buttontext;
  // ignore: prefer_typing_uninitialized_variables
  final void Function()? onPressed;
  final Color buttoncolor;
  final Size minimumSize;
  final double buttontextsize;

  // ignore: use_key_in_widget_constructors
   const CustomFillButton({ required this.buttontext, required this.buttoncolor,required this.onPressed,required this.minimumSize, required this.buttontextsize});

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttoncolor, // blue background color
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: minimumSize
                ),
                child:  Text(buttontext,style:  TextStyle(color: Colors.white,fontSize: buttontextsize),),
              );
  }
}



class OutlineButtonCustom extends StatelessWidget {
  final String buttontext;
  final VoidCallback onPressed;
  final Color buttoncolor;
  final Size minimumSize; 
  final double buttontextsize;

  // ignore: use_key_in_widget_constructors
   const OutlineButtonCustom({
    required this.buttontext,
    required this.buttoncolor,
    required this.onPressed,
   required this.minimumSize, required this.buttontextsize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttoncolor, 
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: buttoncolor), 
        minimumSize: minimumSize, 
      ),
      child: Text(
        buttontext,
        style: TextStyle(
          color: buttoncolor,
          fontSize: buttontextsize,
        ),
      ),
    );
  }
}
