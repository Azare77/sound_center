// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';

class StreamActionMenu extends StatelessWidget {
  const StreamActionMenu({super.key, required this.stream});

  final StreamSubEntity stream;

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
                    BlocProvider.of<StreamBloc>(
                      context,
                    ).add(UnSubscribeFromStream(stream));
                  }
                  Navigator.pop(context);
                },
                child: Text(S.of(context).unsubscribe),
              ),
              TextButton(
                onPressed: () {
                  if (!Platform.isLinux) {
                    SharePlus.instance.share(ShareParams(text: stream.url));
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
