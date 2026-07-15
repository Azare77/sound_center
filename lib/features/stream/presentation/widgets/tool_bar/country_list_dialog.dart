import 'package:flutter/material.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class CountryListDialog extends StatefulWidget {
  const CountryListDialog({super.key});

  @override
  State<CountryListDialog> createState() => _CountryListDialogState();
}

class _CountryListDialogState extends State<CountryListDialog> {
  List<Map<String, dynamic>> raw = [
    {"name": "US", "stationcount": 7476},
    {"name": "DE", "stationcount": 6013},
    {"name": "RU", "stationcount": 3147},
    {"name": "FR", "stationcount": 2683},
    {"name": "MX", "stationcount": 2669},
    {"name": "GB", "stationcount": 2290},
    {"name": "GR", "stationcount": 2163},
    {"name": "CN", "stationcount": 2156},
    {"name": "AU", "stationcount": 2049},
    {"name": "IT", "stationcount": 1716},
    {"name": "BR", "stationcount": 1544},
    {"name": "CA", "stationcount": 1526},
    {"name": "NL", "stationcount": 1376},
    {"name": "ES", "stationcount": 1337},
    {"name": "IN", "stationcount": 1143},
    {"name": "PL", "stationcount": 1139},
    {"name": "RO", "stationcount": 1064},
    {"name": "PH", "stationcount": 999},
    {"name": "AR", "stationcount": 801},
    {"name": "TR", "stationcount": 793},
    {"name": "AE", "stationcount": 774},
    {"name": "ID", "stationcount": 657},
    {"name": "CH", "stationcount": 630},
    {"name": "CO", "stationcount": 614},
    {"name": "CL", "stationcount": 605},
    {"name": "BE", "stationcount": 505},
    {"name": "RS", "stationcount": 404},
    {"name": "HU", "stationcount": 379},
    {"name": "UG", "stationcount": 368},
    {"name": "AT", "stationcount": 347},
    {"name": "PT", "stationcount": 344},
    {"name": "UA", "stationcount": 341},
    {"name": "BG", "stationcount": 332},
    {"name": "HR", "stationcount": 313},
    {"name": "CZ", "stationcount": 302},
    {"name": "SE", "stationcount": 288},
    {"name": "IE", "stationcount": 277},
    {"name": "PE", "stationcount": 250},
    {"name": "DK", "stationcount": 246},
    {"name": "NZ", "stationcount": 237},
    {"name": "ZA", "stationcount": 217},
    {"name": "TW", "stationcount": 213},
    {"name": "JP", "stationcount": 203},
    {"name": "SK", "stationcount": 177},
    {"name": "FI", "stationcount": 175},
    {"name": "VE", "stationcount": 171},
    {"name": "IL", "stationcount": 171},
    {"name": "UY", "stationcount": 170},
    {"name": "EC", "stationcount": 167},
    {"name": "BA", "stationcount": 157},
    {"name": "SI", "stationcount": 139},
    {"name": "SA", "stationcount": 133},
    {"name": "LV", "stationcount": 128},
    {"name": "AF", "stationcount": 124},
    {"name": "NO", "stationcount": 118},
    {"name": "EE", "stationcount": 118},
    {"name": "KR", "stationcount": 110},
    {"name": "DO", "stationcount": 109},
    {"name": "LT", "stationcount": 107},
    {"name": "GH", "stationcount": 106},
    {"name": "BY", "stationcount": 106},
    {"name": "HK", "stationcount": 91},
    {"name": "TH", "stationcount": 90},
    {"name": "MY", "stationcount": 87},
    {"name": "LK", "stationcount": 86},
    {"name": "MD", "stationcount": 81},
    {"name": "NG", "stationcount": 79},
    {"name": "KE", "stationcount": 79},
    {"name": "TN", "stationcount": 77},
    {"name": "BO", "stationcount": 76},
    {"name": "GT", "stationcount": 75},
    {"name": "LB", "stationcount": 73},
    {"name": "PK", "stationcount": 72},
    {"name": "DZ", "stationcount": 72},
    {"name": "PY", "stationcount": 69},
    {"name": "MA", "stationcount": 67},
    {"name": "SG", "stationcount": 65},
    {"name": "SV", "stationcount": 64},
    {"name": "MK", "stationcount": 64},
    {"name": "CR", "stationcount": 59},
    {"name": "HN", "stationcount": 56},
    {"name": "CY", "stationcount": 52},
    {"name": "ME", "stationcount": 52},
    {"name": "EG", "stationcount": 51},
    {"name": "JM", "stationcount": 51},
    {"name": "PR", "stationcount": 50},
    {"name": "RE", "stationcount": 47},
    {"name": "VN", "stationcount": 47},
    {"name": "AL", "stationcount": 44},
    {"name": "KZ", "stationcount": 44},
    {"name": "AZ", "stationcount": 41},
    {"name": "ET", "stationcount": 36},
    {"name": "HT", "stationcount": 36},
    {"name": "SN", "stationcount": 35},
    {"name": "LU", "stationcount": 35},
    {"name": "SY", "stationcount": 33},
    {"name": "IR", "stationcount": 33},
    {"name": "MO", "stationcount": 32},
    {"name": "GE", "stationcount": 32},
    {"name": "NP", "stationcount": 30},
  ];
  List<String> countries = [];
  late List<String> searchCountries;

  @override
  void initState() {
    for (Map s in raw) {
      countries.add(s['name']);
    }
    searchCountries = countries;
    super.initState();
  }

  void search(String query) {
    if (query.isEmpty) {
      searchCountries = countries;
    } else {
      searchCountries = countries
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
                  itemCount: searchCountries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextView(searchCountries[index]),
                      ),
                      onTap: () {
                        Navigator.pop(context, searchCountries[index]);
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
