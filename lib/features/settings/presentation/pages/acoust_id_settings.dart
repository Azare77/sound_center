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

  void showImage() async {
    await showDialog(context: context, builder: (context) => _ImageDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).AcoustIdNote),
              GestureDetector(
                onTap: showImage,
                child: Image.asset('assets/acoustid.png'),
              ),
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
      ),
    );
  }

  void submit() {
    if (!(key.isValid())) return;
    settingsRepository.setAcoustIdApikey(key.text.trim());
  }
}

class _ImageDialog extends StatefulWidget {
  const _ImageDialog();

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog>
    with SingleTickerProviderStateMixin {
  final TransformationController transformationController =
      TransformationController();
  TapDownDetails? doubleTapDetails;
  late final AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;
  final TransformationController _transformationController =
      TransformationController();

  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _zoomAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          if (_zoomAnimation != null) {
            _transformationController.value = _zoomAnimation!.value;
          }
        });
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final position = _doubleTapDetails!.localPosition;

    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    final zoom = currentScale > 1 ? 1.0 : 2.5;

    final targetMatrix = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (zoom - 1),
        -position.dy * (zoom - 1),
        0,
        1,
      )
      ..scaleByDouble(zoom, zoom, 1, 1);

    _zoomAnimation =
        Matrix4Tween(
          begin: _transformationController.value.clone(),
          end: targetMatrix,
        ).animate(
          CurvedAnimation(
            parent: _zoomAnimationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _zoomAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            SizedBox(
              width: size.width,
              height: size.height * 0.4,
              child: ClipRect(
                child: GestureDetector(
                  onDoubleTapDown: (details) {
                    _doubleTapDetails = details;
                  },
                  onDoubleTap: _toggleZoom,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1,
                    maxScale: 5,
                    boundaryMargin: const EdgeInsets.all(100),
                    child: Image.asset(
                      'assets/acoustid.png',
                      width: size.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).ok),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
