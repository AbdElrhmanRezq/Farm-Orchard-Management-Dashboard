import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final void Function(String?)? onClick;
  final String hint;
  const CustomTextField({super.key, required this.hint, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        child: TextFormField(
          cursorColor: Colors.black,
          obscureText: hint == 'Password' ? true : false,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return '$hint is empty';
            }
          },
          onSaved: onClick,
          decoration: InputDecoration(
            hintText: hint,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
