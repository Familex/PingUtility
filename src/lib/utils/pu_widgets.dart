// pu == PingUtility

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

var _puBorderRadius = BorderRadius.circular(10.0);
var _puBorder = OutlineInputBorder(
  borderRadius: _puBorderRadius,
  borderSide: BorderSide.none,
);
var _puElevation = 1.5;
// FIXME label in DropdownButtonFormField clips
// FIXME error label in TextFormField overflows
var _puHeight = 55.0;

Widget _puWrapInMaterial(BuildContext context, Widget child) {
  var scheme = Theme.of(context).colorScheme;

  return SizedBox(
    height: _puHeight,
    child: Material(
      elevation: _puElevation,
      shadowColor: scheme.shadow,
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: _puBorderRadius),
      child: child,
    ),
  );
}

InputDecoration _puInputDecoration(
  String? labelText,
  TextStyle? textStyle,
  String? hintText,
  TextStyle? hintStyle,
) {
  return InputDecoration(
    labelText: labelText,
    hintStyle: hintStyle ?? textStyle,
    hintText: hintText,
    floatingLabelStyle: textStyle,
    helperStyle: textStyle,
    border: _puBorder,
    focusedBorder: _puBorder,
    enabledBorder: _puBorder,
    errorBorder: _puBorder,
    disabledBorder: _puBorder,
  );
}

ShapeBorder _puShapeBorder(Color? borderColor) {
  return RoundedRectangleBorder(
    borderRadius: _puBorderRadius,
    side: BorderSide(
      color: borderColor ?? Colors.transparent,
      width: 2.0,
    ),
  );
}

Widget puTextFormField({
  required BuildContext context,
  String? initialValue,
  void Function(String?)? onSaved,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  String? labelText,
  TextStyle? hintStyle,
  String? hintText,
}) {
  var scheme = Theme.of(context).colorScheme;
  var textStyle = TextStyle(color: scheme.onSurface);

  return _puWrapInMaterial(
    context,
    TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      style: textStyle,
      keyboardType: keyboardType,
      decoration: _puInputDecoration(labelText, textStyle, hintText, hintStyle),
    ),
  );
}

Widget puTextField({
  required BuildContext context,
  TextEditingController? controller,
  List<TextInputFormatter>? inputFormatters,
  void Function(String?)? onChanged,
  TextInputType? keyboardType,
  String? labelText,
  TextStyle? hintStyle,
  String? hintText,
}) {
  var scheme = Theme.of(context).colorScheme;
  var textStyle = TextStyle(color: scheme.onSurface);

  return _puWrapInMaterial(
    context,
    TextField(
      controller: controller,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: textStyle,
      keyboardType: keyboardType,
      decoration: _puInputDecoration(labelText, textStyle, hintText, hintStyle),
    ),
  );
}

Widget puButton({
  required BuildContext context,
  required Widget child,
  void Function()? onPressed,
  Color? color,
  Color? textColor,
  Color? borderColor,
}) {
  var scheme = Theme.of(context).colorScheme;

  return MaterialButton(
    onPressed: onPressed,
    elevation: _puElevation,
    height: _puHeight,
    textColor: textColor ?? scheme.onSurface,
    shape: _puShapeBorder(borderColor),
    color: color ?? scheme.surfaceContainer,
    child: child,
  );
}

Widget puDropdownButtonFormField<T>({
  required BuildContext context,
  String? labelText,
  T? value,
  List<DropdownMenuItem<T>>? items,
  void Function(T?)? onChanged,
}) {
  var scheme = Theme.of(context).colorScheme;
  var textStyle = TextStyle(color: scheme.onSurface);

  return _puWrapInMaterial(
    context,
    DropdownButtonFormField(
      value: value,
      items: items,
      dropdownColor: scheme.surfaceContainer,
      onChanged: onChanged,
      decoration: _puInputDecoration(labelText, textStyle, null, null),
    ),
  );
}

Widget puCheckboxListTile({
  required BuildContext context,
  bool? value,
  void Function(bool?)? onChanged,
  Widget? title,
  Widget? secondary,
}) {
  return _puWrapInMaterial(
    context,
    CheckboxListTile(
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      shape: _puShapeBorder(null),
      title: title,
      secondary: secondary,
    ),
  );
}

class PuText extends StatelessWidget {
  const PuText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyLarge;
    return Text(
      text,
      style: textStyle,
    );
  }
}

class PuLabeledCheckbox extends StatelessWidget {
  const PuLabeledCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
  });

  final bool value;
  final void Function(bool?) onChanged;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: _puWrapInMaterial(
        context,
        Row(
          children: <Widget>[
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            if (title != null) Expanded(child: title!),
          ],
        ),
      ),
    );
  }
}
