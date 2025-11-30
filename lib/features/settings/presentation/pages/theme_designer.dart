import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class ThemeDesigner extends StatefulWidget {
  const ThemeDesigner({super.key, this.themeName});

  final String? themeName;

  @override
  State<ThemeDesigner> createState() => _ThemeDesignerState();
}

class _ThemeDesignerState extends State<ThemeDesigner> {
  late Brightness brightness;
  late Color scaffoldBackground;
  late Color thumbColor;
  late Color appBarBackground;
  late Color shadowColor;
  late Color mediaColor;
  late Color iconColor;
  late CustomTextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomTextEditingController(
      validator: (text) {
        final name = text?.trim() ?? "";
        return ThemeManager.getTheme(name) == null && name.isNotEmpty;
      },
    );
    if (widget.themeName != null) _controller.text = widget.themeName!;
    final AppThemeData theme = ThemeManager.current;
    final ThemeData themeData = theme.themeData;
    brightness = themeData.brightness;
    scaffoldBackground = themeData.scaffoldBackgroundColor;
    thumbColor = themeData.sliderTheme.thumbColor ?? Colors.white;
    appBarBackground = themeData.appBarTheme.backgroundColor ?? Colors.white;
    shadowColor = themeData.shadowColor;
    iconColor = themeData.iconTheme.color ?? Colors.white;
    mediaColor = theme.mediaColor;
  }

  @override
  Widget build(BuildContext context) {
    AppThemeData themeData = AppThemeData.fromSeed(
      id: _controller.text.trim(),
      brightness: brightness,
      scaffoldBackground: scaffoldBackground,
      thumbColor: thumbColor,
      appBarBackground: appBarBackground,
      shadowColor: shadowColor,
      mediaColor: mediaColor,
      iconColor: iconColor,
    );
    return Theme(
      data: themeData.themeData,
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 15,
                    children: [
                      TextFieldBox(
                        controller: _controller,
                        errorText: S.of(context).nameIsUsed,
                        labelText: S.of(context).themeName,
                        maxLines: 1,
                        enabled: widget.themeName == null,
                        textInputAction: TextInputAction.done,
                        margin: EdgeInsets.only(top: 10),
                        validator: (text) {
                          if (widget.themeName != null) return true;
                          final name = text?.trim() ?? "";
                          return ThemeManager.getTheme(name) == null;
                        },
                      ),
                      RadioGroup<Brightness>(
                        onChanged: (v) {
                          setState(() => brightness = v!);
                        },
                        groupValue: brightness,
                        child: Row(
                          mainAxisAlignment: .spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => brightness = Brightness.light),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Radio<Brightness>(value: Brightness.light),
                                    Text(S.of(context).light),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  setState(() => brightness = Brightness.dark),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Radio<Brightness>(value: Brightness.dark),
                                    Text(S.of(context).dark),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ItemEntry(
                        text: S.of(context).appBarBackground,
                        color: appBarBackground,
                        onChanged: (current) =>
                            setState(() => appBarBackground = current),
                      ),
                      _ItemEntry(
                        text: S.of(context).scaffoldBackground,
                        color: scaffoldBackground,
                        onChanged: (current) =>
                            setState(() => scaffoldBackground = current),
                      ),
                      _ItemEntry(
                        text: S.of(context).shadowColor,
                        color: shadowColor,
                        onChanged: (current) =>
                            setState(() => shadowColor = current),
                      ),
                      _ItemEntry(
                        text: S.of(context).iconColor,
                        color: iconColor,
                        onChanged: (current) =>
                            setState(() => iconColor = current),
                      ),
                      _ItemEntry(
                        text: S.of(context).thumbColor,
                        color: thumbColor,
                        onChanged: (current) =>
                            setState(() => thumbColor = current),
                      ),
                      _ItemEntry(
                        text: S.of(context).currentMediaColor,
                        color: mediaColor,
                        onChanged: (current) =>
                            setState(() => mediaColor = current),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.themeName == null &&
                              !_controller.isValid()) {
                            int allCustomThemes =
                                ThemeManager.allCustomThemes.length;
                            _controller.text =
                                "Custom Theme-${allCustomThemes + 1}";
                          }
                          AppThemeData themeData = AppThemeData.fromSeed(
                            id: _controller.text.trim(),
                            brightness: brightness,
                            scaffoldBackground: scaffoldBackground,
                            thumbColor: thumbColor,
                            appBarBackground: appBarBackground,
                            shadowColor: shadowColor,
                            mediaColor: mediaColor,
                            iconColor: iconColor,
                          );
                          ThemeManager.addCustomTheme(themeData);
                          BlocProvider.of<SettingBloc>(
                            context,
                          ).add(ChangeTheme(themeData.id));
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).ok),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CurrentMedia(key: ValueKey(mediaColor), color: mediaColor),
          ],
        ),
      ),
    );
  }
}

class _ItemEntry extends StatelessWidget {
  const _ItemEntry({
    required this.text,
    required this.color,
    required this.onChanged,
  });

  final String text;
  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: color,
                  onColorChanged: onChanged,
                  hexInputBar: true,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(S.of(context).ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          Text(text),
          Spacer(),
          Card(
            shape: CircleBorder(),
            margin: EdgeInsets.zero,
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
