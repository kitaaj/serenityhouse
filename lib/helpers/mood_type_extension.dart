import 'package:mental_health_support/enums/mood_type.dart';

extension MoodTypeExtension on MoodType {
  String? get spotifyUrl {
    if (spotifyPlaylistId == null) return null;
    return 'https://open.spotify.com/playlist/$spotifyPlaylistId';
  }

  bool get hasSpotifyPlaylist => spotifyPlaylistId != null;
}
