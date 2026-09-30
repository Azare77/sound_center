import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/categories.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_list_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/category_list_template.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.category,
    required this.items,
    required this.playlists,
    required this.query,
  });

  final Category category;
  final List<AudioEntity> items;
  final List<PlayListEntity> playlists;
  final String query;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<List<Object>>? _future;

  bool get _isGrouped =>
      widget.category == Category.artists ||
      widget.category == Category.albums ||
      widget.category == Category.folders ||
      widget.category == Category.genres;

  @override
  void initState() {
    super.initState();
    if (_isGrouped) _future = _load();
  }

  @override
  void didUpdateWidget(CategoryPage old) {
    super.didUpdateWidget(old);
    if (_isGrouped && !identical(old.items, widget.items)) {
      _future = _load();
    }
  }

  static String _norm(String s) =>
      s.replaceAll('ي', 'ی').replaceAll('ك', 'ک').toLowerCase();

  List<AudioEntity> _filterAudios(List<AudioEntity> audios) {
    final q = _norm(widget.query);
    if (q.isEmpty) return audios;
    return audios
        .where(
          (a) =>
              _norm(a.title).contains(q) ||
              _norm(a.artist).contains(q) ||
              _norm(a.album).contains(q),
        )
        .toList();
  }

  List<Object> _filterGrouped(List<Object> data) {
    final q = _norm(widget.query);
    if (q.isEmpty) return data;
    return data.where((e) {
      final name = switch (e) {
        ArtistEntity a => a.name,
        AlbumEntity a => a.name,
        GenreEntity g => g.name,
        _ => '',
      };
      return _norm(name).contains(q);
    }).toList();
  }

  Future<List<Object>> _load() async {
    final songs = widget.items;
    return switch (widget.category) {
      Category.artists => AudioUtil.groupSongs<ArtistEntity>(
        allSongs: songs,
        key: (s) => s.artist,
        builder: (name, duration, audios, albums) => ArtistEntity(
          name: name,
          totalLength: duration,
          totalAudios: audios,
          totalAlbums: albums,
        ),
      ),
      Category.albums => AudioUtil.groupSongs<AlbumEntity>(
        allSongs: songs,
        key: (s) => s.album,
        builder: (name, duration, audios, albums) =>
            AlbumEntity(name: name, totalLength: duration, totalAudios: audios),
      ),
      Category.genres => AudioUtil.groupSongs<GenreEntity>(
        allSongs: songs,
        key: (s) => s.genre,
        builder: (name, duration, audios, albums) =>
            GenreEntity(name: name, totalLength: duration, totalAudios: audios),
      ),

      Category.folders => AudioUtil.groupSongsByFolder(allSongs: songs),

      _ => Future.value(const <Object>[]),
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.category == Category.favorites) {
      return AudioListTemplate(_filterAudios(widget.items));
    }

    if (widget.category == Category.playlists) {
      return CategoryListTemplate(
        key: const ValueKey('playlists'),
        category: Category.playlists,
        items: widget.playlists,
      );
    }

    if (!_isGrouped) {
      return AudioListTemplate(_filterAudios(widget.items));
    }

    return FutureBuilder<List<Object>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        final data = snapshot.data;

        if (data == null) {
          return Loading(label: S.of(context).scanning);
        }

        return CategoryListTemplate(
          key: ValueKey(widget.category.name),
          category: widget.category,
          items: _filterGrouped(data),
        );
      },
    );
  }
}
