import 'package:discrimination_checker/models/case_model.dart';
import 'package:discrimination_checker/services/rag_service.dart';
import 'package:discrimination_checker/services/remote_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart'; 
import 'package:intl/intl.dart'; // Added package dependency for live Hugging Face calls

// --- Model Layer classes ---


class ChatMessage {
  final String text;
  final bool isSupport;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isSupport, required this.timestamp});
}
// --- Presentation UI Layer ---
class ChatScreen extends StatefulWidget {
  final CaseModel? caseModel;
  const ChatScreen({super.key, this.caseModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Welcome to D-Check support. How can we help today?', 
      isSupport: true,
      timestamp: DateTime.now(),
    ),
  ];
  
  bool _useRemoteAi = false;
  bool _isLoading = false;
  String _discriminationHint = '';
  bool _possibleDiscrimination = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isSupport: false, timestamp: DateTime.now()));
      _isLoading = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    String answer;
    try {
      if (_useRemoteAi) {
        final localContext = RagService.instance.answer(text);
        answer = await RemoteAiService.instance.answerWithContext(text, localContext);
      } else {
        answer = RagService.instance.answer(text);
      }
    } catch (e) {
      answer = "An error occurred while connecting to the system. Please try again.";
    }

    final grounds = RagService.instance.detectDiscriminationGrounds(text);
    final hasFlag = grounds.isNotEmpty;
    final hint = hasFlag
        ? 'Possible discrimination grounds detected: ${grounds.join(', ')}.'
        : 'No specific discrimination grounds were detected from this message.';

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: answer, isSupport: true, timestamp: DateTime.now()));
      _isLoading = false;
      _possibleDiscrimination = hasFlag;
      _discriminationHint = hint;
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: 'Welcome to D-Check support. How can we help today?', 
        isSupport: true,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
      _discriminationHint = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fixed: Removed duplicate layout strings to keep the title clean.
    final appBarTitle = widget.caseModel?.category ?? 'Support Chat';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear conversation',
            onPressed: _clearConversation,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Settings and Discrimination Alerts Panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Remote AI mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Switch(
                        value: _useRemoteAi,
                        onChanged: (value) => setState(() => _useRemoteAi = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uses a Hugging Face API key for optional remote model responses. If not configured, this app falls back to local legal search.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  if (_discriminationHint.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _possibleDiscrimination ? Colors.orange.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _possibleDiscrimination ? Colors.orange.shade700 : Colors.green.shade700),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _possibleDiscrimination ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: _possibleDiscrimination ? Colors.orange.shade800 : Colors.green.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _discriminationHint,
                              style: TextStyle(
                                fontSize: 13,
                                color: _possibleDiscrimination ? Colors.orange.shade900 : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_isLoading)
              LinearProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                minHeight: 3,
              ),
            // Chat bubble window
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final formattedTime = DateFormat('jm').format(message.timestamp);

                  return Align(
                    alignment: message.isSupport ? Alignment.centerLeft : Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: message.isSupport ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: message.isSupport ? Colors.blue.shade50 : Colors.blue.shade700,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(message.isSupport ? 0 : 18),
                              bottomRight: Radius.circular(message.isSupport ? 18 : 0),
                            ),
                          ),
                          child: MarkdownBody(
                            data: message.text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: message.isSupport ? Colors.black87 : Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
                          child: Text(
                            formattedTime,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Input Layout Field
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
