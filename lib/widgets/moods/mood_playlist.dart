import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mental_health_support/enums/mood_type.dart';
import 'package:mental_health_support/helpers/mood_type_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class MoodPlaylist extends StatelessWidget {
  final MoodType mood;

  const MoodPlaylist({required this.mood, super.key});

  @override
  Widget build(BuildContext context) {
    if (!mood.hasSpotifyPlaylist) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,

        // color: Theme.of(context).colorScheme.onPrimaryContainer,
        child: ListTile(
          onTap: () => _launchSpotify(mood.spotifyUrl, context),
          leading: SvgPicture.asset(
            'assets/icons/spotify_logo.svg',
            width: 40,
            height: 40,
          ),
          title: Text(
            '${mood.label} Playlist for You',
            // style: TextStyle(
            //   color: Theme.of(context).colorScheme.onPrimary,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
          subtitle: Text(
            "A playlist to help you navigate what you're feeling now.",
            // style: Theme.of(context).textTheme.bodySmall!.copyWith(
            //   color: Theme.of(context).colorScheme.onPrimary,
            // ),
          ),
          trailing: Icon(
            Icons.play_arrow,
            // color: Theme.of(context).colorScheme.onPrimary,
            size: 32,
          ),
        ),
      ),
    );
  }

  void _launchSpotify(String? url, BuildContext context) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Spotify playlist available for this mood.')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch Spotify.')));
    }
  }
}
