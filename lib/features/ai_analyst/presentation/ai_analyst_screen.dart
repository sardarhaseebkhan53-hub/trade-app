import 'package:flutter/material.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class AiAnalystScreen extends StatefulWidget {
  const AiAnalystScreen({super.key});

  @override
  State<AiAnalystScreen> createState() => _AiAnalystScreenState();
}

class _AiAnalystScreenState extends State<AiAnalystScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });

    // Simulate structured AI response (in real build this would call backend AI)
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final response = _generateMockResponse(text);
    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(text: response, isUser: false));
      _isLoading = false;
    });
  }

  String _generateMockResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('bullish') || lower.contains('why')) {
      return 'BTC is showing bullish structure on the 4H and daily timeframes.\n\nSupporting: Positive MACD crossover, price holding above key EMAs, rising volume.\n\nRisks: Resistance at recent highs and elevated volatility.\n\nInvalidation: Sustained close below the recent swing low.';
    }
    if (lower.contains('risk')) {
      return 'Key risks right now are:\n• Proximity to major resistance\n• Rising volatility (regime: high volatility)\n• Potential for fakeout around key levels';
    }
    return 'Current market regime is trending with moderate volatility. BTC bias remains constructive on higher timeframes while ETH shows more range-bound behavior.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AurumAppBar(title: 'AURUM AI Analyst'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AurumSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AurumColors.gold.withValues(alpha: 0.15) : AurumColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg.text, style: AurumTypography.body),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: AurumColors.gold),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, 8, AurumSpacing.lg, AurumSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Ask about the market...'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AurumColors.gold),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
