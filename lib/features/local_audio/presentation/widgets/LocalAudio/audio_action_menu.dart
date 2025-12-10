import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';

class AudioActionMenu extends StatelessWidget {
  const AudioActionMenu({super.key, required this.audio});

  final AudioEntity audio;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 5,
            children: [
              TextButton(
                onPressed: () async {
                  bool res =
                      await showDialog(
                        context: context,
                        builder: (_) => ConfirmDialog(),
                      ) ??
                      false;
                  if (res) {
                    BlocProvider.of<LocalBloc>(
                      // ignore: use_build_context_synchronously
                      context,
                    ).add(DeleteAudio(audio));
                  }
                  Navigator.pop(context);
                },
                child: Text(S.of(context).delete),
              ),
              TextButton(
                onPressed: () {
                  if (!Platform.isLinux) {
                    SharePlus.instance.share(
                      ShareParams(files: [XFile(audio.path)]),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(S.of(context).share),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
