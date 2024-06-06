import 'package:ayna/core/usecases/usecase.dart';
import 'package:ayna/features/home/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../repositories/home_repository.dart';

class CacheMessageUseCase implements UseCase<NoParams, MessageModel> {
  final HomeRepository repository;

  const CacheMessageUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(MessageModel message) async {
    final response = repository.cacheMessage(message);
    return Right(response);
  }
}

class GetMessagesUseCase implements UseCase<List<MessageModel>, NoParams> {
  final HomeRepository repository;

  const GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageModel>>> call(NoParams params) async {
    final response = repository.getMessages();
    return Right(response);
  }
}
