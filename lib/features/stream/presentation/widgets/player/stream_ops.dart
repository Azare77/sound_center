import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:url_launcher/url_launcher.dart';

class StreamOps extends StatelessWidget {
  const StreamOps({super.key});

  @override
  Widget build(BuildContext context) {
    final playerRepository = StreamPlayerRepositoryImp();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () async {
            late final String? url;
            final currentStream = playerRepository.getCurrentStream;
            if (currentStream is AudioModel) {
              url = currentStream.uri;
            } else if (currentStream is Source) {
              url = currentStream.listenUrl;
            }
            if (url != null) {
              Uri uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          icon: Icon(Icons.language_rounded),
        ),
        SizedBox(
          width: 40,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
        MediaControllerButton(
          width: 50,
          height: 50,
          onPressed: () async {
            final currentStream = playerRepository.getCurrentStream;
            if (currentStream is Source) {
              if (currentStream.uuid != null) {
                final params = {'station': currentStream.uuid};
                final uri = Uri(
                  scheme: 'https',
                  host: 'azare77.github.io',
                  path: '/stream',
                  queryParameters: params,
                );
                await SharePlus.instance.share(ShareParams(uri: uri));
              } else {
                await SharePlus.instance.share(
                  ShareParams(text: currentStream.listenUrl),
                );
              }
            } else if (currentStream is AudioModel) {
              await SharePlus.instance.share(
                ShareParams(text: currentStream.uri),
              );
            }
          },
          svg: "assets/icons/share.svg",
        ),
      ],
    );
  }
}
