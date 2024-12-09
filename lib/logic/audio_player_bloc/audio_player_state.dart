part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final PlayerState playerState;
  final Map<String, dynamic>? currentEpisode;
  final Map<String, dynamic>? currentPodcast;
  final Duration currentPosition;
  final Duration? totalDuration;

  const AudioPlayerState({
    this.playerState = PlayerState.stopped,
    this.currentEpisode,
    this.currentPodcast,
    this.currentPosition = Duration.zero,
    this.totalDuration,
  });

  AudioPlayerState copyWith({
    PlayerState? playerState,
    Map<String, dynamic>? currentEpisode,
    Map<String, dynamic>? currentPodcast,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return AudioPlayerState(
      playerState: playerState ?? this.playerState,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  bool get isPlaying => playerState == PlayerState.playing;

  @override
  List<Object?> get props => [
        playerState,
        currentEpisode,
        currentPodcast,
        currentPosition,
        totalDuration
      ];
}
