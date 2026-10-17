import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/util/text_util.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/stream_info.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class RadioStreamView extends StatefulWidget {
  const RadioStreamView({
    super.key,
    required this.stream,
    required this.repository,
    required this.subscribe,
  });

  final StreamSubEntity stream;
  final StreamRepositoryImp repository;
  final Function(StreamSubEntity sub) subscribe;

  @override
  State<RadioStreamView> createState() => _RadioStreamViewState();
}

class _RadioStreamViewState extends State<RadioStreamView> {
  final ScrollController _sliverScrollController = ScrollController();
  bool toolbarCollapsed = false;
  bool subscribed = false;
  radio.Station? station;

  @override
  void initState() {
    super.initState();
    double totalExpandableRange = EXPANDED_HEIGHT - kToolbarHeight;
    _sliverScrollController.addListener(() {
      bool hasClient = _sliverScrollController.hasClients;
      bool isOffsetBigger =
          _sliverScrollController.offset > totalExpandableRange;
      setState(() {
        if (!toolbarCollapsed && hasClient && isOffsetBigger) {
          toolbarCollapsed = true;
        } else if (toolbarCollapsed && hasClient && !isOffsetBigger) {
          toolbarCollapsed = false;
        }
      });
    });
    _init();
  }

  Future<void> _init() async {
    final res = await widget.repository.loadStationInfo(widget.stream.uuid!);
    if (res == null) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
      return;
    }
    station = res;
    _checkSubscription();
  }

  void _checkSubscription() async {
    final result = await widget.repository.isSubscribed(station!.url);
    if (!mounted) return;
    setState(() => subscribed = result);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final ColorScheme cs = themeData.colorScheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _sliverScrollController,
      slivers: [
        SliverAppBar(
          toolbarHeight: kToolbarHeight,
          elevation: 2,
          shadowColor: themeData.appBarTheme.shadowColor,
          backgroundColor: themeData.appBarTheme.backgroundColor,
          pinned: true,
          floating: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            color: toolbarCollapsed ? themeData.iconTheme.color : Colors.white,
          ),
          title: AnimatedOpacity(
            opacity: toolbarCollapsed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Text(station?.name ?? widget.stream.title),
          ),
          expandedHeight: EXPANDED_HEIGHT,
          flexibleSpace: StreamInfo(
            subscribe: widget.subscribe,
            subscribed: subscribed,
            station: station,
            heroTag: widget.stream.uuid!,
            cover: widget.stream.cover,
          ),
        ),
        SliverToBoxAdapter(
          child: Material(
            color: themeData.scaffoldBackgroundColor,
            child: Focus(
              onFocusChange: (f) async {
                if (f) {
                  final offset = _sliverScrollController.offset;
                  for (int i = 0; i <= 500; i++) {
                    _sliverScrollController.jumpTo(offset);
                    await Future.delayed(Duration(milliseconds: 1));
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 20, right: 8),
                child: station == null
                    ? SizedBox(
                        height:
                            MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            EXPANDED_HEIGHT,
                        child: const Center(child: Loading()),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatsRow(station: station!, colorScheme: cs),
                            FilledButton.icon(
                              onPressed: () {
                                BlocProvider.of<StreamBloc>(
                                  context,
                                ).add(PlayStream(Source.fromStation(station!)));
                              },
                              label: Text(S.of(context).play),
                              icon: Icon(Icons.play_arrow_rounded),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _InfoCard(
                              children: [
                                _InfoTile(
                                  icon: Icons.radio,
                                  label: S.of(context).title,
                                  value: station!.name,
                                ),
                                _InfoTile(
                                  icon: Icons.public,
                                  label: S.of(context).country,
                                  value:
                                      TextUtil.getCountryName(
                                        station!.countryCode,
                                      ) ??
                                      '',
                                ),
                                if (station!.language != null &&
                                    station!.language!.isNotEmpty)
                                  _InfoTile(
                                    icon: Icons.translate,
                                    label: S.of(context).language,
                                    value: station!.language!,
                                  ),
                                if (station!.codec != null ||
                                    station!.bitrate > 0)
                                  _InfoTile(
                                    icon: Icons.graphic_eq,
                                    label: S.of(context).format,
                                    value: [
                                      if (station!.codec != null)
                                        station!.codec!,
                                      if (station!.bitrate > 0)
                                        '${station!.bitrate} kbps',
                                    ].join('  •  '),
                                  ),
                                if (station!.tags != null &&
                                    station!.tags!.isNotEmpty)
                                  _TagsTile(
                                    label: S.of(context).tags,
                                    tags: station!.tags!
                                        .split(',')
                                        .map((t) => t.trim())
                                        .where((t) => t.isNotEmpty)
                                        .toList(),
                                    colorScheme: cs,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _WebsiteButton(url: station!.url, colorScheme: cs),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// چند ردیف اطلاعات (_InfoTile / _TagsTile) را پشت سر هم، بدون پس‌زمینه‌ی
/// جدا از صفحه، فقط با دیوایدرهای نازک بین‌شان نگه می‌دارد.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon, size: 18, color: theme.iconTheme.color),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsTile extends StatelessWidget {
  const _TagsTile({
    required this.label,
    required this.tags,
    required this.colorScheme,
  });

  final String label;
  final List<String> tags;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.sell_outlined,
              size: 18,
              color: theme.iconTheme.color,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          labelStyle: theme.textTheme.bodySmall,
                          backgroundColor: colorScheme.secondaryContainer,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.station, required this.colorScheme});

  final radio.Station station;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            icon: Icons.thumb_up_alt_outlined,
            value: station.votes.toString(),
            label: S.of(context).votes,
            colorScheme: colorScheme,
          ),
        ),
        Expanded(
          child: _StatBox(
            icon: Icons.bar_chart_rounded,
            value: station.clickCount.toString(),
            label: S.of(context).clicks,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String value;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        spacing: 5,
        children: [
          Icon(icon, size: 20, color: theme.iconTheme.color),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebsiteButton extends StatelessWidget {
  const _WebsiteButton({required this.url, required this.colorScheme});

  final String url;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: 10,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.language,
                  size: 18,
                  color: theme.iconTheme.color,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).website,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
