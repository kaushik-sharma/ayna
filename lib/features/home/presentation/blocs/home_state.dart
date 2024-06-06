part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;

  const factory HomeState.initializingWs() = _InitializingWs;

  const factory HomeState.initializedWs() = _InitializedWs;

  const factory HomeState.initWsSuccess() = _InitWsSuccess;

  const factory HomeState.initWsFailure() = _InitWsFailure;

  const factory HomeState.sessionReset() = _SessionReset;

  const factory HomeState.cachedMessagesFetched(List<MessageModel> messages) =
      _CachedMessagesFetched;

  const factory HomeState.filteredByChannelId(List<MessageModel> messages,
      List<String> channelIds, String channelId) = _FilteredByChannelId;

  const factory HomeState.chatSectionHidden() = _ChatSectionHidden;
}
