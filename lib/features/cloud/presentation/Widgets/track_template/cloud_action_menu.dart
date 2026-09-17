// ignore_for_file: use_build_context_synchronously

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';

class CloudActionMenu extends StatelessWidget {
  const CloudActionMenu({super.key, required this.track});

  final dynamic track;

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
              if (track is CloudTrack)
                TextButton(
                  onPressed: () async {
                    bool res =
                        await showDialog(
                          context: context,
                          builder: (_) => ConfirmDialog(),
                        ) ??
                        false;
                    if (res) {
                      BlocProvider.of<CloudBloc>(
                        context,
                      ).add(RemoveFromHistory(track: track));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).delete),
                ),
              TextButton(
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(uri: track.shareLink),
                  );
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
