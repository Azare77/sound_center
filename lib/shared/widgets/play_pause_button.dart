import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // آیکون پلی/پاز
        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              isPlaying ? 'assets/icons/pause.svg' : 'assets/icons/play.svg',
              width: 30,
              height: 30,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

        // لودینگ دایره‌ای (فقط اگه isLoading == true)
        if (isLoading)
          SizedBox(
            width: 55,
            height: 55,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
