import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Sound Center"),
        actions: [
          PopupMenuButton<AudioColumns>(
            icon: Icon(Icons.sort_rounded),
            onSelected: (value) {
              BlocProvider.of<LocalBloc>(context).add(Search(column: value));
            },
            itemBuilder: (context) => [
              // گزینه‌های مرتب‌سازی بر اساس ستون‌ها
              PopupMenuItem(
                value: AudioColumns.title,
                child: TextView('Title'),
              ),
              PopupMenuItem(
                value: AudioColumns.artist,
                child: TextView('Artist'),
              ),
              PopupMenuItem(
                value: AudioColumns.album,
                child: TextView('Album'),
              ),
              PopupMenuItem(
                value: AudioColumns.createdAt,
                child: TextView('Create time'),
              ),
              PopupMenuItem(
                value: AudioColumns.duration,
                child: TextView('Duration'),
              ),
              const PopupMenuDivider(),
            ],
          ),
        ],
      ),
      body: Column(children: [Expanded(child: LocalAudios())]),
    );
  }
}
