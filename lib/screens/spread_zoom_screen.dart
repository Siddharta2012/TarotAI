import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tarot_models.dart';
import '../widgets/user_status_bar.dart';
import '../widgets/tarot_card_widget.dart';

class SpreadZoomScreen extends StatefulWidget {
  final List<DrawnCard> cards;
  const SpreadZoomScreen({super.key, required this.cards});

  @override
  State<SpreadZoomScreen> createState() => _SpreadZoomScreenState();
}

class _SpreadZoomScreenState extends State<SpreadZoomScreen> {
  bool _isTopCardVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esplora la Stesa')),
      body: Column(
        children: [
          const UserStatusBar(),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100.0),
              minScale: 0.2,
              maxScale: 4.0,
              child: Center(
                child: _buildFullCelticCrossLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCelticCrossLayout() {
    const double cardWidth = 100.0;
    const double cardHeight = 150.0;
    const double hGap = 25.0;
    const double vGap = 25.0;

    final double contentWidth = (cardWidth * 4) + (hGap * 3);
    final double contentHeight = (cardHeight * 4) + (vGap * 3);

    return SizedBox(
      width: contentWidth,
      height: contentHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: cardHeight + vGap, left: 0, child: TarotCardWidget(card: widget.cards[3])),
          Positioned(top: cardHeight + vGap, left: (cardWidth + hGap) * 2, child: TarotCardWidget(card: widget.cards[5])),
          Positioned(top: 0, left: cardWidth + hGap, child: TarotCardWidget(card: widget.cards[4])),
          Positioned(top: (cardHeight + vGap) * 2, left: cardWidth + hGap, child: TarotCardWidget(card: widget.cards[2])),
          Positioned(
            top: cardHeight + vGap,
            left: cardWidth + hGap,
            child: GestureDetector(
              onTap: () {
                if (!_isTopCardVisible) {
                  setState(() { _isTopCardVisible = true; });
                }
              },
              child: TarotCardWidget(card: widget.cards[0]),
            ),
          ),
          Positioned(
            top: cardHeight + vGap,
            left: cardWidth + hGap,
            child: Visibility(
              visible: _isTopCardVisible,
              child: GestureDetector(
                onTap: () {
                  setState(() { _isTopCardVisible = false; });
                },
                child: Transform.rotate(
                  angle: pi / 2,
                  child: TarotCardWidget(card: widget.cards[1]),
                ),
              ),
            ),
          ),
          Positioned(top: 0, left: (cardWidth + hGap) * 3, child: TarotCardWidget(card: widget.cards[9])),
          Positioned(top: cardHeight + vGap, left: (cardWidth + hGap) * 3, child: TarotCardWidget(card: widget.cards[8])),
          Positioned(top: (cardHeight + vGap) * 2, left: (cardWidth + hGap) * 3, child: TarotCardWidget(card: widget.cards[7])),
          Positioned(top: (cardHeight + vGap) * 3, left: (cardWidth + hGap) * 3, child: TarotCardWidget(card: widget.cards[6])),
        ],
      ),
    );
  }
}
