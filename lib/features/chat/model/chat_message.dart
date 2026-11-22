enum ChatRole { user, bot }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.isError = false,
    this.includeInHistory = true,
  });

  final ChatRole role;
  final String text;
  final bool isError;

  /// Sapaan awal dan pesan galat tidak dikirim sebagai riwayat ke chatbot.
  final bool includeInHistory;

  Map<String, dynamic> toJson() => {
        'peran': role == ChatRole.user ? 'user' : 'bot',
        'isi': text,
      };
}