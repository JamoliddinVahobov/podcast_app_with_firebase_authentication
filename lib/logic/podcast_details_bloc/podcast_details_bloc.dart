import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcast_app/models/podcast_model.dart';
import '../../models/episode_model.dart';
import '../../repositories/abstract_repository.dart';
part 'podcast_details_event.dart';
part 'podcast_details_state.dart';

class PodcastDetailsBloc
    extends Bloc<PodcastDetailsEvent, PodcastDetailsState> {
  final PodcastRepository _repository;
  final int _limit = 30;

  PodcastDetailsBloc(Podcast initialPodcast,
      {required PodcastRepository repository})
      : _repository = repository,
        super(PodcastDetailsState(podcast: initialPodcast)) {
    on<LoadPodcastDetails>(_onLoadPodcastDetails);
    on<LoadMoreEpisodes>(_onLoadMoreEpisodes);
  }

  Future<void> _onLoadPodcastDetails(
      LoadPodcastDetails event, Emitter<PodcastDetailsState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final episodesJson = await _repository.fetchEpisodes(
        event.podcastId,
        offset: 0,
        limit: _limit,
      );

      final episodes = List<Episode>.from(
        episodesJson.map((episodeJson) {
          if (episodeJson is Map<String, dynamic>) {
            return Episode.fromJson(episodeJson as Map<String, dynamic>);
          }
          throw const FormatException('Invalid episode format');
        }),
      );

      // Update the podcast with the new episodes
      final updatedPodcast = Podcast(
        id: state.podcast.id,
        name: state.podcast.name,
        publisher: state.podcast.publisher,
        imageUrl: state.podcast.imageUrl,
        description: state.podcast.description,
        episodes: episodes,
      );

      emit(
        state.copyWith(
          podcast: updatedPodcast,
          episodes: episodes,
          isLoading: false,
          hasReachedMax: episodes.length < _limit,
          currentOffset: episodes.length,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      print('Error loading podcast details: $e');
    }
  }

  Future<void> _onLoadMoreEpisodes(
      LoadMoreEpisodes event, Emitter<PodcastDetailsState> emit) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final moreEpisodesJson = await _repository.fetchEpisodes(
        event.podcastId,
        offset: state.currentOffset!,
        limit: _limit,
      );

      final moreEpisodes = List<Episode>.from(
        moreEpisodesJson.map((episodeJson) {
          if (episodeJson is Map<String, dynamic>) {
            return Episode.fromJson(episodeJson as Map<String, dynamic>);
          }
          throw const FormatException('Invalid episode format');
        }),
      );

      final updatedEpisodes = [...state.episodes, ...moreEpisodes];

      // Update the podcast with all episodes
      final updatedPodcast = Podcast(
        id: state.podcast.id,
        name: state.podcast.name,
        publisher: state.podcast.publisher,
        imageUrl: state.podcast.imageUrl,
        description: state.podcast.description,
        episodes: updatedEpisodes,
      );

      emit(state.copyWith(
        podcast: updatedPodcast,
        episodes: updatedEpisodes,
        currentOffset: updatedEpisodes.length,
        hasReachedMax: moreEpisodes.length < _limit,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
      print('Error loading more podcast episodes: $e');
    }
  }
}
