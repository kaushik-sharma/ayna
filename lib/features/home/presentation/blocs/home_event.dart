part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.initWs() = _InitWs;

  const factory HomeEvent.sendMessage(String channelId, String text) =
      _SendMessage;

  const factory HomeEvent.resetSession(String channelId) = _ResetSession;

  const factory HomeEvent.getCachedMessages() = _GetCachedMessages;

  const factory HomeEvent.filterByChannelId(String channelId) =
      _FilterByChannelId;
}
