import 'package:flutter/material.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

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
    key = CustomTextEditingController();
    secret = CustomTextEditingController();
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
            Text("Select Your Provider"),
            RadioGroup<PodcastProvider>(
              onChanged: (v) => setState(() => provider = v!),
              groupValue: provider,
              child: Row(
                children: PodcastProvider.values.map((p) {
                  return InkWell(
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
              TextFieldBox(
                controller: key,
                hintText: 'Key',
                validator: (text) {
                  return text?.isNotEmpty ?? false;
                },
              ),
            if (provider == PodcastProvider.podcatIndex)
              TextFieldBox(
                controller: secret,
                hintText: 'secret',
                validator: (text) {
                  return text?.isNotEmpty ?? false;
                },
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  submit();
                  Navigator.pop(context);
                },
                child: Text('submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submit() {
    if (provider == PodcastProvider.podcatIndex) {
      if (!(key.isValid() && secret.isValid())) return;
      settingsRepository.setPodcastIndexKeys(
        key.text.trim(),
        secret.text.trim(),
      );
    }
    settingsRepository.setPodcastProvider(provider);
  }
}
