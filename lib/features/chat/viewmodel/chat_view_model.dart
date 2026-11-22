import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/chat_repository.dart';
import '../model/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  final ChatRepository _repository;

  final List<ChatMessage> _messages = [
    const ChatMessage(
      role: ChatRole.bot,
      text:
          'Halo! Saya asisten Yap Coffee. Mau tanya soal menu, pemesanan, atau pengambilan?',
      includeInHistory: false,
    ),
  ];

  bool _isSending = false;
  bool _disposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _isSending) return;

    final history = _messages.where((m) => m.includeInHistory).toList();

    _messages.add(ChatMessage(role: ChatRole.user, text: text));
    _isSending = true;
    _notify();

    try {
      final answer = await _repository.ask(text, history);
      _messages.add(ChatMessage(role: ChatRole.bot, text: answer));
    } on ApiException catch (e) {
      _messages.add(ChatMessage(
        role: ChatRole.bot,
        text: e.message,
        isError: true,
        includeInHistory: false,
      ));
    } catch (_) {
      _messages.add(const ChatMessage(
        role: ChatRole.bot,
        text: 'Terjadi kesalahan, coba lagi nanti.',
        isError: true,
        includeInHistory: false,
      ));
    }

    _isSending = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}