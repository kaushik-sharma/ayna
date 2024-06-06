import 'package:ayna/core/usecases/usecase.dart';
import 'package:ayna/features/home/data/datasources/home_local_datasource.dart';
import 'package:ayna/features/home/data/models/message_model.dart';
import 'package:ayna/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource datasource;

  const HomeRepositoryImpl(this.datasource);

  @override
  NoParams cacheMessage(MessageModel message) {
    datasource.saveMessage(message);
    return const NoParams();
  }

  @override
  List<MessageModel> getMessages() {
    return datasource.getMessages();
  }
}
