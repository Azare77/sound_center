import 'package:flutter/material.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class LanguageListDialog extends StatefulWidget {
  const LanguageListDialog({super.key});

  @override
  State<LanguageListDialog> createState() => _LanguageListDialogState();
}

class _LanguageListDialogState extends State<LanguageListDialog> {
  List<Map<String, dynamic>> raw = [
    {"name": "english", "iso_639": "en", "stationcount": 12275},
    {"name": "spanish", "iso_639": "es", "stationcount": 5046},
    {"name": "german", "iso_639": "de", "stationcount": 4251},
    {"name": "chinese", "iso_639": "zh", "stationcount": 2203},
    {"name": "french", "iso_639": "fr", "stationcount": 2164},
    {"name": "russian", "iso_639": "ru", "stationcount": 1761},
    {"name": "italian", "iso_639": "it", "stationcount": 1307},
    {"name": "greek", "iso_639": "el", "stationcount": 1151},
    {"name": "polish", "iso_639": "pl", "stationcount": 818},
    {"name": "dutch", "iso_639": "nl", "stationcount": 789},
    {"name": "portuguese", "iso_639": "pt", "stationcount": 672},
    {"name": "arabic", "iso_639": "ar", "stationcount": 569},
    {"name": "hindi", "iso_639": "hi", "stationcount": 483},
    {"name": "american english", "iso_639": null, "stationcount": 463},
    {"name": "brazilian portuguese", "iso_639": null, "stationcount": 408},
    {"name": "romanian", "iso_639": "ro", "stationcount": 332},
    {"name": "tamil", "iso_639": "ta", "stationcount": 318},
    {"name": "serbian", "iso_639": "sr", "stationcount": 315},
    {"name": "turkish", "iso_639": "tr", "stationcount": 283},
    {"name": "hungarian", "iso_639": "hu", "stationcount": 263},
    {"name": "español mexico", "iso_639": null, "stationcount": 240},
    {"name": "croatian", "iso_639": "hr", "stationcount": 213},
    {"name": "română", "iso_639": null, "stationcount": 211},
    {"name": "romania", "iso_639": null, "stationcount": 197},
    {"name": "czech", "iso_639": "cs", "stationcount": 194},
    {"name": "ukrainian", "iso_639": "uk", "stationcount": 194},
    {"name": "japanese", "iso_639": "ja", "stationcount": 189},
    {"name": "indonesian", "iso_639": "id", "stationcount": 185},
    {"name": "filipino", "iso_639": null, "stationcount": 157},
    {"name": "castellano. español", "iso_639": null, "stationcount": 154},
    {"name": "swedish", "iso_639": "sv", "stationcount": 152},
    {"name": "español argentina", "iso_639": null, "stationcount": 138},
    {"name": "bulgarian", "iso_639": "bg", "stationcount": 132},
    {"name": "english uk", "iso_639": null, "stationcount": 132},
    {"name": "язык: русский", "iso_639": null, "stationcount": 129},
    {"name": "engilsh", "iso_639": null, "stationcount": 128},
    {"name": "slovak", "iso_639": "sk", "stationcount": 126},
    {"name": "español internacional", "iso_639": null, "stationcount": 122},
    {"name": "cantonese", "iso_639": "yue", "stationcount": 119},
    {"name": "español - latinoamerica", "iso_639": null, "stationcount": 110},
    {"name": "malayalam", "iso_639": "ml", "stationcount": 108},
    {"name": "português  brasil", "iso_639": null, "stationcount": 107},
    {"name": "bosnian", "iso_639": "bs", "stationcount": 106},
    {"name": "finnish", "iso_639": "fi", "stationcount": 105},
    {"name": "danish", "iso_639": "da", "stationcount": 103},
    {"name": "catalan", "iso_639": "ca", "stationcount": 101},
    {"name": "português (brasil)", "iso_639": null, "stationcount": 101},
    {"name": "korean", "iso_639": "ko", "stationcount": 99},
    {"name": "british english", "iso_639": null, "stationcount": 91},
    {"name": "hebrew", "iso_639": "he", "stationcount": 87},
    {"name": "slovenian", "iso_639": "sl", "stationcount": 85},
    {"name": "deutsch fränkisch", "iso_639": null, "stationcount": 84},
    {"name": "punjabi", "iso_639": null, "stationcount": 77},
    {"name": "luganda", "iso_639": null, "stationcount": 77},
    {"name": "bahasa indonesia", "iso_639": null, "stationcount": 71},
    {"name": "portugues do brasil", "iso_639": null, "stationcount": 68},
    {"name": "espanish", "iso_639": null, "stationcount": 67},
    {"name": "akan", "iso_639": "ak", "stationcount": 66},
    {"name": "românä", "iso_639": null, "stationcount": 65},
    {"name": "urdu", "iso_639": "ur", "stationcount": 60},
    {"name": "pt-br", "iso_639": null, "stationcount": 59},
    {"name": "norwegian", "iso_639": "no", "stationcount": 59},
    {"name": "ukranian", "iso_639": null, "stationcount": 58},
    {"name": "francaise", "iso_639": null, "stationcount": 57},
    {"name": "estonian", "iso_639": "et", "stationcount": 57},
    {"name": "thai", "iso_639": "th", "stationcount": 56},
    {"name": "espaňol", "iso_639": null, "stationcount": 55},
    {"name": "swiss german", "iso_639": "gsw", "stationcount": 55},
    {"name": "latvian", "iso_639": "lv", "stationcount": 54},
    {"name": "español chile", "iso_639": null, "stationcount": 54},
    {"name": "español colombia", "iso_639": null, "stationcount": 47},
    {"name": "mandarin", "iso_639": "cmn", "stationcount": 41},
    {"name": "hokkien", "iso_639": null, "stationcount": 39},
    {"name": "macedonian", "iso_639": "mk", "stationcount": 37},
    {"name": "sinhala", "iso_639": "si", "stationcount": 37},
    {"name": "lithuanian", "iso_639": "lt", "stationcount": 34},
    {"name": "malay", "iso_639": "ms", "stationcount": 33},
    {"name": "swahili", "iso_639": "sw", "stationcount": 33},
    {"name": "turkçe", "iso_639": null, "stationcount": 33},
    {"name": "persian", "iso_639": "fa", "stationcount": 32},
    {"name": "kurdish", "iso_639": "ku", "stationcount": 32},
    {"name": "azerbaijani", "iso_639": "az", "stationcount": 32},
    {"name": "kannada", "iso_639": "kn", "stationcount": 32},
    {"name": "deu", "iso_639": null, "stationcount": 30},
    {"name": "kazakh", "iso_639": "kk", "stationcount": 29},
    {"name": "português (br)", "iso_639": null, "stationcount": 28},
    {"name": "georgian", "iso_639": "ka", "stationcount": 27},
    {"name": "belarusian", "iso_639": "be", "stationcount": 27},
    {"name": "english/russian", "iso_639": null, "stationcount": 27},
    {"name": "afrikaans", "iso_639": "af", "stationcount": 25},
    {"name": "tagalog", "iso_639": "tl", "stationcount": 25},
    {"name": "montenegro", "iso_639": null, "stationcount": 23},
    {"name": "english/", "iso_639": null, "stationcount": 23},
    {"name": "flemish", "iso_639": null, "stationcount": 22},
    {"name": "mongolian", "iso_639": "mn", "stationcount": 21},
    {"name": "rus", "iso_639": null, "stationcount": 21},
    {"name": "albanian", "iso_639": "sq", "stationcount": 21},
    {"name": "bangla", "iso_639": null, "stationcount": 21},
    {"name": "telugu", "iso_639": "te", "stationcount": 19},
    {"name": "low german", "iso_639": "nds", "stationcount": 19},
  ];
  List<String> languages = [];
  late List<String> searchLanguage;

  @override
  void initState() {
    for (Map s in raw) {
      languages.add(s['name']);
    }
    searchLanguage = languages;
    super.initState();
  }

  void search(String query) {
    if (query.isEmpty) {
      searchLanguage = languages;
    } else {
      searchLanguage = languages
          .where((item) => item.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFieldBox(onChanged: search),
              Flexible(
                child: ListView.builder(
                  itemCount: searchLanguage.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextView(searchLanguage[index]),
                      ),
                      onTap: () {
                        Navigator.pop(context, searchLanguage[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
