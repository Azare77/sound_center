import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sound_center/features/stream/data/source/radio_browser.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class LanguageListDialog extends StatefulWidget {
  const LanguageListDialog({super.key, this.currentLanguage});

  final String? currentLanguage;

  @override
  State<LanguageListDialog> createState() => _LanguageListDialogState();
}

class _LanguageListDialogState extends State<LanguageListDialog> {
  List<Map<String, dynamic>> raw = [];
  late List<Map<String, dynamic>> searchLanguage;
  late final TextEditingController query;
  Map? current;

  @override
  void initState() {
    query = TextEditingController();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  Future<void> _init() async {
    final languages = await RadioBrowser().getLanguages();

    if (languages != null) {
      raw =
          languages
              .where((c) => c.name.trim().isNotEmpty)
              .map(
                (c) => {
                  'name': capitalize(c.name.trim()),
                  'languageCode': c.iso639,
                  'stationCount': c.stationCount,
                },
              )
              .toList()
            ..sort((a, b) {
              final nameA = a['name'] as String;
              final nameB = b['name'] as String;

              final aSpecial = RegExp(r'^[0-9#+]').hasMatch(nameA);
              final bSpecial = RegExp(r'^[0-9#+]').hasMatch(nameB);

              // مواردی که با عدد یا # شروع می‌شوند آخر بروند
              if (aSpecial && !bSpecial) return 1;
              if (!aSpecial && bSpecial) return -1;

              return nameA.compareTo(nameB);
            });
    } else {
      raw = [
        {"name": "Afrikaans", "languageCode": "af"},
        {"name": "Akan", "languageCode": "ak"},
        {"name": "Albanian", "languageCode": "sq"},
        {"name": "Arabic", "languageCode": "ar"},
        {"name": "Azerbaijani", "languageCode": "az"},
        {"name": "Belarusian", "languageCode": "be"},
        {"name": "Bosnian", "languageCode": "bs"},
        {"name": "Bulgarian", "languageCode": "bg"},
        {"name": "Cantonese", "languageCode": "yue"},
        {"name": "Catalan", "languageCode": "ca"},
        {"name": "Chinese", "languageCode": "zh"},
        {"name": "Croatian", "languageCode": "hr"},
        {"name": "Czech", "languageCode": "cs"},
        {"name": "Danish", "languageCode": "da"},
        {"name": "Dutch", "languageCode": "nl"},
        {"name": "English", "languageCode": "en"},
        {"name": "Estonian", "languageCode": "et"},
        {"name": "Finnish", "languageCode": "fi"},
        {"name": "French", "languageCode": "fr"},
        {"name": "Georgian", "languageCode": "ka"},
        {"name": "German", "languageCode": "de"},
        {"name": "Greek", "languageCode": "el"},
        {"name": "Hebrew", "languageCode": "he"},
        {"name": "Hindi", "languageCode": "hi"},
        {"name": "Hungarian", "languageCode": "hu"},
        {"name": "Indonesian", "languageCode": "id"},
        {"name": "Italian", "languageCode": "it"},
        {"name": "Japanese", "languageCode": "ja"},
        {"name": "Kannada", "languageCode": "kn"},
        {"name": "Kazakh", "languageCode": "kk"},
        {"name": "Korean", "languageCode": "ko"},
        {"name": "Kurdish", "languageCode": "ku"},
        {"name": "Latvian", "languageCode": "lv"},
        {"name": "Lithuanian", "languageCode": "lt"},
        {"name": "Low german", "languageCode": "nds"},
        {"name": "Macedonian", "languageCode": "mk"},
        {"name": "Malay", "languageCode": "ms"},
        {"name": "Malayalam", "languageCode": "ml"},
        {"name": "Mandarin", "languageCode": "cmn"},
        {"name": "Mongolian", "languageCode": "mn"},
        {"name": "Norwegian", "languageCode": "no"},
        {"name": "Persian", "languageCode": "fa"},
        {"name": "Polish", "languageCode": "pl"},
        {"name": "Portuguese", "languageCode": "pt"},
        {"name": "Romanian", "languageCode": "ro"},
        {"name": "Russian", "languageCode": "ru"},
        {"name": "Serbian", "languageCode": "sr"},
        {"name": "Sinhala", "languageCode": "si"},
        {"name": "Slovak", "languageCode": "sk"},
        {"name": "Slovenian", "languageCode": "sl"},
        {"name": "Spanish", "languageCode": "es"},
        {"name": "Swahili", "languageCode": "sw"},
        {"name": "Swedish", "languageCode": "sv"},
        {"name": "Swiss german", "languageCode": "gsw"},
        {"name": "Tagalog", "languageCode": "tl"},
        {"name": "Tamil", "languageCode": "ta"},
        {"name": "Telugu", "languageCode": "te"},
        {"name": "Thai", "languageCode": "th"},
        {"name": "Turkish", "languageCode": "tr"},
        {"name": "Ukrainian", "languageCode": "uk"},
        {"name": "Urdu", "languageCode": "ur"},
      ];
    }
    current = raw.firstWhereOrNull(
      (item) => item['name'] == widget.currentLanguage,
    );
    search(query.text.trim());
  }

  void search(String query) {
    if (query.isEmpty) {
      searchLanguage = raw;
    } else {
      searchLanguage = raw
          .where(
            (item) =>
                item['name'].toLowerCase().startsWith(query.toLowerCase()),
          )
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFieldBox(
              onChanged: search,
              autofocus: true,
              controller: query,
              labelText: S.of(context).language,
              maxLines: 1,
            ),
            if (current != null) ...[TextView(current!['name']), Divider()],
            Flexible(
              child: raw.isEmpty
                  ? Loading()
                  : ListView.builder(
                      itemCount: searchLanguage.length,
                      itemBuilder: (BuildContext context, int index) {
                        final language = searchLanguage[index];

                        return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: .start,
                              spacing: 2,
                              children: [
                                Text(language['name']),
                                if (language['stationCount'] != null)
                                  Text(
                                    "${S.of(context).stationCount} : ${language['stationCount'].toString()}",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(
                              context,
                              language['name'].toString().toLowerCase(),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
