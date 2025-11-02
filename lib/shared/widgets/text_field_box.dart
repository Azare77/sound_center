import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldBox extends StatefulWidget {
  const TextFieldBox({
    super.key,
    this.controller,
    this.textInputType,
    this.labelText,
    this.isPassword = false,
    this.enabled = true,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.onSubmitted,
    this.inputFormatters,
    this.suffix,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.maxLines,
    this.textInputAction = TextInputAction.none,
    this.textDirection,
    this.useBorder = true,
    this.hintText,
    this.onFocusChanged,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final String? labelText;
  final String? hintText;
  final bool? enabled;
  final bool autofocus;
  final bool useBorder;
  final int? maxLength;
  final int? maxLines;
  final bool canRequestFocus;
  final Widget? suffix;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String text)? onSubmitted;
  final bool Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Function(FocusNode focuseNode)? onFocusChanged;
  final TextDirection? textDirection;
  final List<String>? autofillHints;

  @override
  State<TextFieldBox> createState() => _TextFieldBoxState();
}

class _TextFieldBoxState extends State<TextFieldBox> {
  bool isValid() {
    if (widget.validator == null || widget.controller == null) {
      return true;
    }
    return widget.validator!(widget.controller!.text.trim());
  }

  final FocusNode focusNode = FocusNode();
  CustomTextEditingController? controller;
  TextDirection? textDirection;

  void _handleTextChange(String value) {
    if (widget.textDirection == null) {
      // اگر شامل کاراکترهای راست به چپ باشد، جهت را تغییر بده
      if (RegExp(r'[\u0600-\u06FF]').hasMatch(value)) {
        setState(() {
          textDirection = TextDirection.rtl;
        });
      } else {
        setState(() {
          textDirection = TextDirection.ltr;
        });
      }
    }
  }

  @override
  void initState() {
    textDirection = widget.textDirection;
    if (widget.controller is CustomTextEditingController) {
      controller = widget.controller as CustomTextEditingController;
      controller?.validator ??= widget.validator;
    }
    super.initState();
    if (widget.validator != null) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          setState(() {});
        }
        if (widget.onFocusChanged != null) {
          widget.onFocusChanged!(focusNode);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: controller ?? widget.controller,
        obscureText: widget.isPassword,
        keyboardType: widget.textInputType,
        onSubmitted: widget.onSubmitted,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        textDirection: textDirection,
        autofocus: widget.autofocus,
        autofillHints: widget.autofillHints,
        style: const TextStyle(fontFamily: "Vazir", color: Colors.white),
        inputFormatters: widget.inputFormatters,
        onChanged: (String value) {
          _handleTextChange(value);
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        focusNode: focusNode,
        canRequestFocus: widget.canRequestFocus,
        decoration: InputDecoration(
          labelText: widget.labelText,
          contentPadding: const EdgeInsets.all(10.0),
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontFamily: "Vazir", color: Colors.grey),
          helperStyle: const TextStyle(fontFamily: "Vazir", color: Colors.grey),
          suffixStyle: const TextStyle(
            fontFamily: "Vazir",
            color: Colors.white,
          ),
          counterText: '',
          isDense: false,
          // errorText: '',
          error: widget.validator != null
              ? widget.validator!(widget.controller?.text)
                    ? null
                    : const SizedBox.shrink()
              : null,
          suffix: widget.suffix,
          prefixIcon: widget.prefixIcon,
          labelStyle: const TextStyle(fontFamily: "Vazir", color: Colors.white),
          border: widget.useBorder
              ? const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                )
              : InputBorder.none,
          focusedBorder: widget.useBorder
              ? const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.white),
                )
              : InputBorder.none,
          enabledBorder: widget.useBorder
              ? const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.white),
                )
              : InputBorder.none,
        ),
      ),
    );
  }
}

class CustomTextEditingController extends TextEditingController {
  CustomTextEditingController({this.validator});

  bool Function(String?)? validator;

  bool isValid() {
    if (validator == null) {
      return true;
    }
    return validator!(text.trim());
  }
}

class DotUnderlineInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isNotEmpty &&
        (newValue.text[0] == '_' || newValue.text[0] == '.')) {
      // Prevent input if the first character is _ or .
      return oldValue;
    }
    return newValue;
  }
}
