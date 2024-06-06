import 'dart:async';
import 'dart:developer';

import 'package:ayna/core/usecases/usecase.dart';
import 'package:ayna/features/home/data/models/message_model.dart';
import 'package:ayna/features/home/domain/usecases/usecases.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CacheMessageUseCase cacheMessageUseCase;
  final GetMessagesUseCase getMessagesUseCase;

  final _channels = <String, WebSocketChannel>{};
  final _messages = <MessageModel>[];

  HomeBloc(this.cacheMessageUseCase, this.getMessagesUseCase)
      : super(const HomeState.initial()) {
    on<_InitWs>((event, emit) async {
      try {
        emit(const _InitializingWs());

        final wsUrl = Uri.parse('wss://echo.websocket.org/');
        final channel = WebSocketChannel.connect(wsUrl);
        await channel.ready;

        final channelId = const Uuid().v1();

        _channels.addAll({channelId: channel});

        emit(const _InitializedWs());
        emit(const _InitWsSuccess());

        final completer = Completer();

        channel.stream.listen((event) {
          log(event.toString());

          final now = DateTime.now().millisecondsSinceEpoch;
          final message = MessageModel(
            channelId: channelId,
            id: now.toString(),
            fromUser: false,
            createdAt: now,
            text: event.toString(),
          );

          _messages.add(message);
          cacheMessageUseCase(message);

          add(_FilterByChannelId(channelId));
        });

        await completer.future;
      } on WebSocketChannelException catch (e) {
        log(e.message.toString());
        log(e.toString());
        emit(const _InitWsFailure());
      } catch (e) {
        log(e.toString());
        emit(const _InitWsFailure());
      }
    });
    on<_SendMessage>((event, emit) {
      _channels[event.channelId]!.sink.add(event.text);

      final now = DateTime.now().millisecondsSinceEpoch;
      final message = MessageModel(
          channelId: event.channelId,
          id: now.toString(),
          fromUser: true,
          createdAt: now,
          text: event.text);

      _messages.add(message);
      cacheMessageUseCase(message);

      add(_FilterByChannelId(event.channelId));
    });
    on<_ResetSession>((event, emit) async {
      await _channels[event.channelId]!.sink.close();
      _channels.removeWhere((key, value) => key == event.channelId);
      _messages.removeWhere((element) => element.channelId == event.channelId);
      emit(const _SessionReset());
    });
    on<_GetCachedMessages>((event, emit) async {
      final result = await getMessagesUseCase(const NoParams());
      if (result.isLeft()) return;
      result.fold(
        (_) {},
        (right) {
          _messages.clear();
          _messages.addAll(right);
        },
      );
      if (_messages.isEmpty) return;
      _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final channelId = _messages.first.channelId;
      add(_FilterByChannelId(channelId));
    });
    on<_FilterByChannelId>((event, emit) {
      emit(
        _FilteredByChannelId(
          _messages
              .where((element) => element.channelId == event.channelId)
              .toList()
            ..sort(
              (a, b) => a.createdAt - b.createdAt,
            ),
          _messages.map((e) => e.channelId).toSet().toList(),
          event.channelId,
        ),
      );
    });
    on<_HideChatSection>((event, emit) {
      emit(const _ChatSectionHidden());
    });
  }
}
