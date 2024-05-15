import 'dart:math' as math;
import 'package:blackjack/presentation/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../screen/gameblock.dart';

class FlippedPlayingCard extends StatefulWidget {
  PlayingCard card;
  bool isActive;
  FlippedPlayingCard({super.key, required this.card, required this.isActive});

  @override
  State<FlippedPlayingCard> createState() => _AnimatedSwitcherExampleState();
}

class _AnimatedSwitcherExampleState extends State<FlippedPlayingCard> {

  bool isFront = false;
  bool isAnimated = false;

  @override
  void initState() {
    super.initState();
    if (widget.card.animateHidden) {
      isFront = widget.card.isHidden;
      Future.microtask(() => {
        setState(() {
          isFront = !isFront;
        })
      });
    } else {
      isFront = !widget.card.isHidden;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return _buildFlipAnimation(theme);
  }

  Widget _buildFlipAnimation(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (!widget.isActive) return;
        if (isAnimated) return;
        setState(() => isFront = !isFront);
        isAnimated = true;
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: _transitionBuilder,
        layoutBuilder: (widget, list) {
          return Stack(children: [widget!, ...list]);
        },
        child: isFront ? _getCardOf(widget.card) : _rearCard(theme),
      ),
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: math.pi, end: 0.0).animate(animation);
    rotateAnim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isAnimated = false;
      }
    });
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(isFront) != widget!.key);
        final value = isUnder ? math.min(rotateAnim.value, math.pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  Widget _rearCard(ThemeData theme) {
    return Image.asset(
      key: const ValueKey(false),
      theme.suitAsset,
      height: 150,
      width: 105,
    );
  }

  Widget _getCardOf(PlayingCard element) {
    Widget result;
    if (element is CourtCard) {
      result = Image.asset(
        element.asset,
        height: 150,
        width: 105,
      );
    } else {
      result = SvgPicture.asset(
        element.asset,
        height: 150,
        width: 105,
      );
    }
    return result;
  }
}
