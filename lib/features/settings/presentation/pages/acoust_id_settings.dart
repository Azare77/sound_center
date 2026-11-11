import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/text_util.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:url_launcher/url_launcher.dart';

class AcoustIdSettings extends StatefulWidget {
  const AcoustIdSettings({super.key});

  @override
  State<AcoustIdSettings> createState() => _AcoustIdSettingsState();
}

class _AcoustIdSettingsState extends State<AcoustIdSettings> {
  late final CustomTextEditingController key;
  late final SettingsRepositoryImp settingsRepository;

  @override
  void initState() {
    super.initState();
    key = CustomTextEditingController(
      validator: (text) {
        return text?.isNotEmpty ?? false;
      },
    );

    settingsRepository = SettingsRepositoryImp();

    String? apiKey = settingsRepository.getAcoustIdApikey();
    if (apiKey != null) {
      key.text = apiKey;
    }
  }

  @override
  void dispose() {
    key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
        child: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).importantRegisterYourApplicationToGetAnApiKey),
            Image.asset('assets/acoustid.png'),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextFieldBox(
                controller: key,
                labelText: 'Key',
                textDirection: TextDirection.ltr,
              ),
            ),
            Directionality(
              textDirection: .ltr,
              child: Row(
                mainAxisAlignment: .center,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse("https://acoustid.org");
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      S.of(context).getApiKey,
                      textDirection: TextUtil.getTextDirection(
                        S.of(context).getApiKey,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      submit();
                      Navigator.pop(context);
                    },
                    child: Text(S.of(context).submit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submit() {
    if (!(key.isValid())) return;
    settingsRepository.setAcoustIdApikey(key.text.trim());
  }
}
