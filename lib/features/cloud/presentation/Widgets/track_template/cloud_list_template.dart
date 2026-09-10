import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/cloud_item_template.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/features/cloud/presentation/pages/playlist_info/playlist_detail.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class CloudListTemplate extends StatelessWidget {
  const CloudListTemplate(this.items, {super.key});

  final CloudEntity items;
  static const double _minPlaylistRowHeight = 90.0;
  static const double _sectionSpacing = 12.0;
  static const _sectionTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  bool _isValidItem(dynamic item) =>
      item is CloudTrack || item is CloudPlaylist;

  @override
  Widget build(BuildContext context) {
    final playerRepo = CloudPlayerRepositoryImp();
    if (items.playlists.isEmpty && items.tracks.isEmpty) {
      return const Center(child: TextView("No History"));
    }
    final currentAudio = playerRepo.getCurrentTrack;
    final bool hasTracks = items.tracks.isNotEmpty;
    final bool hasPlaylists = items.playlists.isNotEmpty;

    final double playlistRowHeight = ((MediaQuery.heightOf(context) / 100) * 20)
        .clamp(_minPlaylistRowHeight, double.infinity);

    return CustomScrollView(
      slivers: [
        if (hasPlaylists) ...[
          const SliverPadding(
            padding: EdgeInsetsDirectional.only(
              start: 8.0,
              top: 8.0,
              bottom: 6.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text("Playlists", style: _sectionTitleStyle),
            ),
          ),
          if (!hasTracks)
            // فقط پلی‌لیست داریم -> لیست عمودی کامل با ارتفاع ثابت آیتم
            SliverFixedExtentList(
              itemExtent: LIST_ITEM_HEIGHT,
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildVerticalPlaylistItem(context, index),
                childCount: items.playlists.length,
              ),
            )
          else
            // تراک هم داریم -> نوار افقی، ولی همچنان داخل همون CustomScrollView
            SliverToBoxAdapter(
              child: SizedBox(
                height: playlistRowHeight,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemCount: items.playlists.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = items.playlists[index];
                    if (!_isValidItem(item)) return const SizedBox.shrink();
                    return SizedBox(
                      width: playlistRowHeight,
                      child: _HorizontalPlaylistCard(
                        key: ValueKey(item.id),
                        title: item.title,
                        artworkUrl: item.artworkUrl,
                        heroTag: item.id,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaylistDetail(playlist: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: _sectionSpacing)),
        ],
        if (hasTracks) ...[
          const SliverPadding(
            padding: EdgeInsetsDirectional.only(start: 8.0, bottom: 6.0),
            sliver: SliverToBoxAdapter(
              child: Text("Tracks", style: _sectionTitleStyle),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: LIST_ITEM_HEIGHT,
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items.tracks[index];
              final isCurrent = currentAudio?.id == item.id;
              if (!_isValidItem(item)) return const SizedBox.shrink();
              return Material(
                key: ValueKey(item.id),
                color: isCurrent ? Color(0x1D1BF1D8) : Colors.transparent,
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<CloudBloc>(
                      context,
                    ).add(PlayTrack(tracks: items.tracks, index: index));
                  },
                  child: CloudItemTemplate(item: item),
                ),
              );
            }, childCount: items.tracks.length),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalPlaylistItem(BuildContext context, int index) {
    final item = items.playlists[index];
    if (!_isValidItem(item)) return const SizedBox.shrink();
    return InkWell(
      key: ValueKey(item.id),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaylistDetail(playlist: item)),
        );
      },
      child: CloudItemTemplate(item: item),
    );
  }
}

/// کارت پلی‌لیست در نوار افقی: عکس همیشه مربع می‌ماند (با AspectRatio)
/// و عنوان همیشه یک خط کامل نمایش داده می‌شود، صرف‌نظر از ارتفاع در دسترس.
class _HorizontalPlaylistCard extends StatelessWidget {
  const _HorizontalPlaylistCard({
    super.key,
    required this.title,
    required this.artworkUrl,
    required this.heroTag,
    required this.onTap,
  });

  final String title;
  final String? artworkUrl;
  final Object heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            // عکس تمام فضای باقیمانده (بعد از کسر عنوان) را می‌گیرد
            // و AspectRatio تضمین می‌کند همیشه مربع باشد، حتی اگر
            // فضای عمودی محدود شود.
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkCacheImage(
                      url: artworkUrl,
                      size: null,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
