import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/adapters.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
@HiveType(typeId: 0)
class MessageModel with _$MessageModel {
  const factory MessageModel({
    @HiveField(0) required final String channelId,
    @HiveField(1) required final String id,
    @HiveField(2) required final bool fromUser,
    @HiveField(3) required final int createdAt,
    @HiveField(4) required final String text,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
