import 'package:ayna/features/home/data/models/message_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeLocalDatasource {
  final _messagesBox = Hive.box<Map<String, dynamic>>('messages_box');

  void saveMessage(MessageModel message) {
    // _messagesBox.add(message.toJson());
  }

  List<MessageModel> getMessages() {
    return [];
    // try {
    //   final a = _messagesBox.values as MappedIterable<Frame, Map<String, dynamic>>;
    //   final maps = <Map<String, dynamic>>[];
    //   for (final b in a) {
    //     maps.add(_convertLinkedMapToMap(b));
    //   }
    //   final messages = <MessageModel>[];
    //   for (final map in maps) {
    //     messages.add(MessageModel.fromJson(map));
    //   }
    //   return messages;
    // } catch (e) {
    //   return [];
    // }
  }

  void clear() {
    // _messagesBox.clear();
  }
}
