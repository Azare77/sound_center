import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_audio_repository.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/header_image.dart';
import 'package:sound_center/features/settings/presentation/pages/acoust_id_settings.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';

class MetadataDialog extends StatefulWidget {
  const MetadataDialog({super.key, required this.audio});

  final AudioEntity audio;

  @override
  State<MetadataDialog> createState() => _MetadataDialogState();
}

class _MetadataDialogState extends State<MetadataDialog> {
  late AudioEntity originalAudio;
  late AudioEntity audio;
  Uint8List? cover;

  bool _isLoadingAcoustId = false;
  bool _isLoadingItunes = false;
  bool _isLoadingCover = false;
  bool _isSaving = false;

  bool get _isLoading =>
      _isLoadingAcoustId || _isLoadingItunes || _isLoadingCover || _isSaving;

  String? _error;
  String? step;

  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;
  late final TextEditingController _genreController;
  late final TextEditingController _yearController;

  final repo = LocalAudioRepository();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    audio = widget.audio;
    originalAudio = widget.audio;
  }

  String normalize(String? value) {
    final unknown = S.of(context).unknown;
    if (value == null || value.trim().isEmpty || value.trim() == unknown) {
      return '';
    }

    return value.trim();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final metadata = readMetadata(File(audio.path));
    final title = metadata.title?.trim();
    final album = metadata.album?.trim();
    final artist = audio.artist;
    final genre = metadata.genres.isNotEmpty
        ? metadata.genres.join(',')
        : audio.genre;
    final year = metadata.year?.year;
    originalAudio = originalAudio.copyWith(
      title: title,
      artist: normalize(artist),
      album: normalize(album),
      genre: normalize(genre),
      year: normalize(year != null && year > 0 ? year.toString() : null),
    );

    _titleController = TextEditingController(text: title);

    _artistController = TextEditingController(text: normalize(artist));

    _albumController = TextEditingController(text: normalize(album));

    _genreController = TextEditingController(text: normalize(genre));

    _yearController = TextEditingController(
      text: normalize(year != null && year > 0 ? year.toString() : null),
    );

    cover = audio.cover;
  }

  Future<void> loadData() async {
    if (_isLoading) return;
    if (AppSettingStorage.getAcoustIdApikey() == null) {
      await showDialog(context: context, builder: (_) => AcoustIdSettings());
    }
    if (AppSettingStorage.getAcoustIdApikey() == null) return;

    setState(() {
      _isLoadingAcoustId = true;
      _error = null;
    });

    try {
      void setStep(int step) {
        switch (step) {
          case 0:
            this.step = S.of(context).generatingAudioFingerprint;
            break;
          case 1:
            this.step = S.of(context).lookingUpTrackOnAcoustid;
            break;
          case 2:
            this.step = S.of(context).fetchingMetadataFromMusicbrainz;
            break;
          case 3:
            this.step = S.of(context).searchingForArtwork;
            break;
          default:
            this.step = null;
        }
        setState(() {});
      }

      final AudioEntity? result = await repo.getMetadata(audio, setStep);

      if (!mounted) return;
      if (result == null) {
        ToastMessage.showErrorMessage(title: S.of(context).noMetadata);
        return;
      }

      updateAudio(result);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAcoustId = false;
        });
      }
    }
  }

  Future<void> loadItunesMetadata() async {
    if (_isLoading) return;
    setState(() {
      _isLoadingItunes = true;
      _error = null;
    });

    try {
      final AudioEntity? result = await repo.getItunesMetadata(
        originalAudio,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim(),
      );

      if (!mounted) return;
      if (result == null) {
        ToastMessage.showErrorMessage(title: S.of(context).noMetadata);
        return;
      }
      updateAudio(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingItunes = false;
        });
      }
    }
  }

  void updateAudio(AudioEntity result) {
    audio = result;
    // Update text fields
    _titleController.text = normalize(result.title);
    _artistController.text = normalize(result.artist);
    _albumController.text = normalize(result.album);
    _genreController.text = normalize(result.genre);
    _yearController.text = normalize(result.year);
    cover = result.cover;
  }

  Future<void> selectCover() async {
    final image = await FilePicker.pickFile(type: FileType.image);
    if (image == null) return;
    cover = await image.xFile.readAsBytes();
    setState(() {
      audio = audio.copyWith(cover: cover);
    });
  }

  Future<void> searchCover() async {
    if (_isLoading) return;
    setState(() {
      _isLoadingCover = true;
    });
    final image = await repo.getCover(
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
    );

    if (image == null) {
      setState(() {
        _isLoadingCover = false;
      });
      return;
    }
    cover = image;
    setState(() {
      audio = audio.copyWith(cover: cover);
      _isLoadingCover = false;
    });
  }

  Future<void> saveMetadata() async {
    final localBloc = context.read<LocalBloc>();
    setState(() {
      _isSaving = true;
    });
    final updatedAudio = audio.copyWith(
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
      genre: _genreController.text.trim(),
      genres: _genreController.text.trim().split(','),
      year: _yearController.text.trim(),
      cover: cover,
    );

    try {
      await repo.saveMetadata(audio: updatedAudio, coverBytes: cover);

      AudioUtil.seedCoverCache(updatedAudio.id, CoverSize.thumbnail, cover);

      AudioUtil.seedCoverCache(updatedAudio.id, CoverSize.banner, cover);

      LocalPlayerRepositoryImp().setMetadata(updatedAudio);

      if (!mounted) return;
      final textStyle = ThemeManager.getThemeData(
        ThemeManager.current,
      ).textTheme.bodyMedium;
      ToastMessage.showInfoMessage(
        title: Text(S.of(context).metadataUpdated, style: textStyle),
      );

      Navigator.pop(context);

      await Future.delayed(const Duration(milliseconds: 500));

      localBloc.add(GetLocalAudios());
    } catch (e) {
      if (!mounted) return;
      ToastMessage.showErrorMessage(
        title: S.of(context).failedToUpdateMetadata,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    _yearController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        insetPadding: const EdgeInsets.all(5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: .min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 200,
                        child: HeaderImage(
                          key: ValueKey(cover?.length),
                          id: audio.id,
                          cover: cover,
                        ),
                      ),
                      Row(
                        mainAxisSize: .min,
                        spacing: 10,
                        children: [
                          IconButton(
                            onPressed: selectCover,
                            icon: Icon(Icons.add_a_photo_rounded),
                          ),

                          IconButton(
                            onPressed: searchCover,
                            icon: SizedBox(
                              width: 24,
                              height: 24,
                              child: _isLoadingCover
                                  ? CircularProgressIndicator(strokeWidth: 2)
                                  : Icon(Icons.search_rounded),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                cover = originalAudio.cover;
                                audio = audio.copyWith(cover: cover);
                              });
                            },
                            icon: Icon(Icons.restore_rounded),
                          ),
                        ],
                      ),
                      _buildField(
                        label: S.of(context).title,
                        icon: Icons.music_note_outlined,
                        controller: _titleController,
                        inputType: TextInputType.name,
                        inputAction: TextInputAction.next,
                        onRestorePressed: () =>
                            _titleController.text = originalAudio.title,
                      ),
                      _buildField(
                        label: S.of(context).artist,
                        icon: Icons.person_rounded,
                        controller: _artistController,
                        inputType: TextInputType.name,
                        inputAction: TextInputAction.next,
                        onRestorePressed: () =>
                            _artistController.text = originalAudio.artist,
                      ),
                      _buildField(
                        label: S.of(context).album,
                        icon: Icons.album_rounded,
                        controller: _albumController,
                        inputType: TextInputType.name,
                        inputAction: TextInputAction.next,
                        onRestorePressed: () =>
                            _albumController.text = originalAudio.album,
                      ),
                      _buildField(
                        label: S.of(context).genre,
                        icon: Icons.music_note_rounded,
                        controller: _genreController,
                        inputType: TextInputType.name,
                        inputAction: TextInputAction.next,
                        onRestorePressed: () =>
                            _genreController.text = originalAudio.genre,
                      ),
                      _buildField(
                        label: S.of(context).year,
                        icon: Icons.calendar_month_outlined,
                        controller: _yearController,
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.done,
                        onRestorePressed: () =>
                            _yearController.text = originalAudio.year,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onRestorePressed,
    TextInputAction? inputAction,
    TextInputType? inputType,
    TextInputFormatter? format,
  }) {
    return TextFieldBox(
      controller: controller,
      labelText: label,
      textInputType: inputType,
      inputFormatters: format == null ? [] : [format],
      textCapitalization: TextCapitalization.words,
      textInputAction: inputAction,
      maxLines: 1,
      onSubmitted: (_) {
        if (inputAction == TextInputAction.next) {
          FocusScope.of(context).nextFocus();
        }
      },
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.5),
      ),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            onRestorePressed.call();
          });
        },
        icon: Icon(
          Icons.restore_rounded,
          color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: (_isLoading) ? null : loadData,
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      child: Center(
                        child: _isLoadingAcoustId
                            ? Row(
                                mainAxisSize: .min,
                                spacing: 5,
                                children: [
                                  if (step != null)
                                    Flexible(child: ScrollingText(step!)),
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ],
                              )
                            : ScrollingText(S.of(context).searchUsingAcoustID),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : loadItunesMetadata,
                  child: SizedBox(
                    height: 20,
                    child: Center(
                      child: _isLoadingItunes
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : ScrollingText(S.of(context).searchUsingItnues),
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: _isLoading ? null : saveMetadata,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(S.of(context).save),
          ),
        ],
      ),
    );
  }
}
