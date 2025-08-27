import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String labelText;
  final bool? obscureText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? type;
  const MyTextField({
    super.key,
    required this.labelText,
    this.obscureText,
    required this.controller,
    this.validator,
    this.type,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool obscure;

  @override
  void initState() {
    super.initState();
    obscure = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.white),
        suffixIcon: widget.labelText.toLowerCase() == 'password'
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
                style: ButtonStyle(
                  iconColor: WidgetStateProperty.all(
                    Colors.white,
                  ),
                ),
              )
            : null,
      ),
      obscureText: obscure,
      validator: widget.validator,
      keyboardType: widget.type,
    );
  }
}
