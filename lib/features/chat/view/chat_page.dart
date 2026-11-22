import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../component/chat_avatar.dart';
import '../component/chat_bubble.dart';
import '../component/chat_input_bar.dart';
import '../model/chat_message.dart';
import '../viewmodel/chat_view_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatViewModel _viewModel;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel()..addListener(_scrollToEnd);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_scrollToEnd);
    _viewModel.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        foregroundColor: AppColors.espresso,
        title: const Row(
          children: [
            ChatAvatar(size: 36),
            SizedBox(width: 10),
            Text(
              'Asisten Yap Coffee',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final messages = _viewModel.messages;
          final sending = _viewModel.isSending;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length + (sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == messages.length) {
                      return const ChatBubble(
                        text: 'Sedang mengetik...',
                        isUser: false,
                        muted: true,
                      );
                    }
                    final m = messages[i];
                    return ChatBubble(
                      text: m.text,
                      isUser: m.role == ChatRole.user,
                      isError: m.isError,
                    );
                  },
                ),
              ),
              ChatInputBar(
                enabled: !sending,
                onSend: _viewModel.send,
              ),
            ],
          );
        },
      ),
    );
  }
}