import 'package:flutter/material.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderSettings extends StatefulWidget {
  const ProviderSettings({super.key});

  @override
  State<ProviderSettings> createState() => _ProviderSettingsState();
}

class _ProviderSettingsState extends State<ProviderSettings> {
  late final CustomTextEditingController key;
  late final CustomTextEditingController secret;
  late final SettingsRepositoryImp settingsRepository;
  late PodcastProvider provider;

  @override
  void initState() {
    super.initState();
    key = CustomTextEditingController(
      validator: (text) {
        return text?.isNotEmpty ?? false;
      },
    );
    secret = CustomTextEditingController(
      validator: (text) {
        return text?.isNotEmpty ?? false;
      },
    );
    settingsRepository = SettingsRepositoryImp();
    provider = settingsRepository.getPodcastProvider();
    Map<String, String>? podcastIndexInfo = settingsRepository
        .getPodcastIndexKeys();
    if (podcastIndexInfo != null) {
      key.text = podcastIndexInfo['key'] ?? "";
      secret.text = podcastIndexInfo['secret'] ?? "";
    }
  }

  @override
  void dispose() {
    key.dispose();
    secret.dispose();
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
            Text(S.of(context).selectProvider),
            RadioGroup<PodcastProvider>(
              onChanged: (v) => setState(() => provider = v!),
              groupValue: provider,
              child: Row(
                children: PodcastProvider.values.map((p) {
                  return GestureDetector(
                    onTap: () => setState(() => provider = p),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Radio<PodcastProvider>(value: p),
                          Text(p.name),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (provider == PodcastProvider.podcatIndex)
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextFieldBox(
                  controller: key,
                  labelText: 'Key',
                  textDirection: TextDirection.ltr,
                ),
              ),
            if (provider == PodcastProvider.podcatIndex)
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextFieldBox(
                  controller: secret,
                  labelText: 'secret',
                  textDirection: TextDirection.ltr,
                ),
              ),
            Row(
              mainAxisAlignment: .center,
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    submit();
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).submit),
                ),
                if (provider == PodcastProvider.podcatIndex)
                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse("https://api.podcastindex.org");
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: Text("Get Api Key"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void submit() {
    settingsRepository.setPodcastIndexKeys(key.text.trim(), secret.text.trim());
    if (provider == PodcastProvider.podcatIndex) {
      if (!(key.isValid() && secret.isValid())) return;
    }
    settingsRepository.setPodcastProvider(provider);
  }
}
