import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/pages/episode/podcast_detail.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/subscribed/subscribe_template.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class SubscribedPodcastList extends StatelessWidget {
  const SubscribedPodcastList(this.podcasts, {super.key});

  final List<SubscriptionEntity> podcasts;

  @override
  Widget build(BuildContext context) {
    if (podcasts.isEmpty) return const Center(child: TextView("NO Podcast!!"));
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 2 ستون
        crossAxisSpacing: 16, // فاصله افقی
        mainAxisSpacing: 16, // فاصله عمودی
        childAspectRatio: 0.78, // نسبت عرض به ارتفاع (مربعی‌تر)
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return InkWell(
          key: Key(podcast.feedUrl),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PodcastDetail(feedUrl: podcast.feedUrl),
              ),
            );
          },
          child: SubscribeTemplate(podcast: podcast),
        );
      },
    );
  }
}
