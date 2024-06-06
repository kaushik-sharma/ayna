import 'dart:async';

import 'package:ayna/core/helpers/ui_helpers.dart';
import 'package:ayna/core/widgets/custom_app_bar.dart';
import 'package:ayna/core/widgets/custom_text_field.dart';
import 'package:ayna/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:ayna/features/home/data/models/message_model.dart';
import 'package:ayna/router/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/custom_button.dart';
import '../../../../di.dart';
import '../../../../gen/assets.gen.dart';
import '../blocs/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final GifController _gifController;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? _channelId;
  final _messages = <MessageModel>[];
  final _channelIds = <String>[];

  final _authBloc = sl<AuthBloc>();
  final _homeBloc = sl<HomeBloc>();

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeBloc.add(const HomeEvent.getCachedMessages());
    });
  }

  @override
  void dispose() {
    _gifController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          initializingWs: () {},
          initializedWs: () {},
          initWsSuccess: () {},
          initWsFailure: () {
            UiHelpers.showSnackBar('Failed to connect.',
                mode: SnackBarMode.error);
          },
          sessionReset: () {
            _messages.clear();
            _messageController.clear();
            _channelIds.removeWhere((element) => element == _channelId);
            _channelId = null;
          },
          cachedMessagesFetched: (messages) {
            _messages.clear();
            _messages.addAll(messages);
          },
          filteredByChannelId: (messages, channelIds, channelId) {
            _messages.clear();
            _messages.addAll(messages);
            _channelIds.clear();
            _channelIds.addAll(channelIds);
            _channelId = channelId;
            _messageController.clear();
          },
        );
      },
      builder: (context, state) => Scaffold(
        appBar: kCustomAppBar(
          'Home',
          actions: [
            CustomButton(
              type: ButtonType.text,
              onTap: _signOut,
              prefixIcon: Icons.logout_rounded,
              text: 'Log out',
              foregroundColor: Colors.red,
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey, width: 1.r),
            ),
          ),
          child: _buildDesktopView(),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final completer = Completer<bool>();
    final subscription = _authBloc.stream.listen((state) {
      state.maybeWhen<void>(
        orElse: () {},
        signOutSuccess: () => completer.complete(true),
        signOutFailure: () => completer.complete(false),
      );
    });

    UiHelpers.showLoadingOverlay(context);

    _authBloc.add(const AuthEvent.signOut());

    final result = await completer.future;

    await subscription.cancel();
    UiHelpers.hideLoadingOverlay();

    if (!result) {
      UiHelpers.showSnackBar('Failed to log out.', mode: SnackBarMode.error);
      return;
    }

    context.goNamed(Routes.auth.name);
  }

  Widget _buildDesktopView() => Row(
        children: [
          SizedBox(
            width: 400.w,
            child: _buildSessionsList(),
          ),
          Expanded(child: _buildChatSection()),
        ],
      );

  Widget _buildSessionsList() {
    Widget buildCard(int index, String channelId) => InkWell(
          onTap: () {
            _channelId = channelId;
            _homeBloc.add(HomeEvent.filterByChannelId(channelId));
          },
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 1.h))),
            padding: EdgeInsets.all(20.h),
            child: Row(
              children: [
                Container(
                  width: 60.h,
                  height: 60.h,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: const ShapeDecoration(shape: CircleBorder()),
                  child: Image.network(
                    'https://www.shutterstock.com/image-vector/young-smiling-man-avatar-brown-600nw-2261401207.jpg',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                20.horizontalSpace,
                Expanded(
                    child: Text(
                  'Channel ${index + 1}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 28.h, color: Colors.black),
                ))
              ],
            ),
          ),
        );

    return SizedBox(
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
                border:
                    Border(right: BorderSide(color: Colors.grey, width: 1.h))),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _channelIds.length,
              itemBuilder: (context, index) =>
                  buildCard(index, _channelIds[index]),
            ),
          ),
          Positioned(
            right: 20.h,
            bottom: 20.h,
            child: IconButton(
              onPressed: () {
                _homeBloc.add(const HomeEvent.initWs());
              },
              icon: const Icon(Icons.add),
              iconSize: 100.h,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    if (_messages.isEmpty) return _buildIllustration();

    Widget buildBubble(MessageModel message) => Align(
          alignment:
              message.fromUser ? Alignment.centerLeft : Alignment.centerRight,
          child: UnconstrainedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: message.fromUser
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Card(
                  color: message.fromUser ? Colors.black : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: message.fromUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(
                  timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(message.createdAt)),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 50.w,
        vertical: 30.h,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 100.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) => buildBubble(_messages[index]),
              separatorBuilder: (context, index) => 20.verticalSpace,
            ),
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _messageController,
                  validator: (_) => null,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  hintText: 'Type your message...',
                ),
              ),
              20.horizontalSpace,
              IconButton(
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  _homeBloc.add(HomeEvent.sendMessage(_channelId!, text));
                },
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                color: Colors.black,
              ),
              20.horizontalSpace,
              IconButton(
                onPressed: () {
                  _homeBloc.add(HomeEvent.resetSession(_channelId!));
                },
                icon: const Icon(Icons.delete),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() => SizedBox.square(
        dimension: 700.h,
        child: Gif(
          controller: _gifController,
          fit: BoxFit.contain,
          autostart: Autostart.once,
          image: AssetImage(
            Assets.gifs.messages.path,
          ),
          onFetchCompleted: () {
            _gifController.forward();
          },
        ),
      );
}
