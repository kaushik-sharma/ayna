import 'package:ayna/core/usecases/usecase.dart';

import '../../data/models/message_model.dart';

abstract class HomeRepository {
  NoParams cacheMessage(MessageModel message);

  List<MessageModel> getMessages();
}
