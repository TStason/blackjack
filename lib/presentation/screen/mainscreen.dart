import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/theme.dart';
import '../widget/animated_card.dart';
import 'gameblock.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Black Jack')),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            Widget widget;
            switch (state) {
              case Initial _: widget = _renderInitialState(
                  theme, () { context.read<GameBloc>().add(InitGame()); }
              );
              case PlayerDraw s1: widget = _renderPlayerDraw(s1, theme);
              case DealerDraw s1:
              // TODO: send delayed action
                Future.delayed(const Duration(seconds: 1),() => {
                  context.read<GameBloc>().add(DealerHitCard())
                });
                widget = _renderDealerDraw(s1, theme);
              case DealerWin s1: widget = _renderDealerWin(context, s1, theme);
              case PlayerWin s1: widget = _renderPlayerWin(context, s1, theme);

              default: widget = Text(
                "$state",
                style: theme.textTheme.displayLarge,
              );
            }
            return widget;
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: Text("T", style: theme.textTheme.displayLarge,),
            // child: const Icon(Icons.add),
            onPressed: () {
              context.read<GameBloc>().add(PlayerHitCard());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: Text("H", style: theme.textTheme.displayLarge,),
            // child: const Icon(Icons.remove),
            onPressed: () {
              context.read<GameBloc>().add(PlayerHold());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _renderInitialState(ThemeData theme, VoidCallback onPressed) {
    final jack = CourtCard(
        value: 0,
        type: Court.JACK,
        suite: CardSuit.SPADES
    );
    jack.animateHidden = true;
    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: onPressed,
              child: Text(
                "Start",
                style: theme.textTheme.displayLarge,
              )
          ),
          FlippedPlayingCard(
              card: jack,
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _renderPlayerDraw(PlayerDraw state, ThemeData theme) {
    return _renderGameStarted(state, theme);
  }

  Widget _renderDealerDraw(DealerDraw state, ThemeData theme) {
    return _renderGameStarted(state, theme);
  }

  Widget _renderDealerWin(BuildContext context, DealerWin state, ThemeData theme) {
    Future.microtask(() => showEndGameDialog(context, "Dealer WIN!"));
    return _renderGameStarted(state, theme);
  }

  Widget _renderPlayerWin(BuildContext context, PlayerWin state, ThemeData theme) {
    Future.microtask(() => showEndGameDialog(context, "You WIN!"));
    return _renderGameStarted(state, theme);
  }

  Widget _getCardRows(List<PlayingCard> hand, ThemeData theme, bool isDealer) {
    List<Row> playerRows = [];
    List<Widget> playerCards = [];
    var rowCount = 0;
    for (var i = 0; i < hand.length; i++) {
      if (rowCount == 3) {
        playerRows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: playerCards.toList(),
        ));
        playerCards.clear();
        rowCount = 0;
      }
      playerCards.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FlippedPlayingCard(
              key: ValueKey(hand[i].hashCode + hand[i].value.hashCode + hand[i].isHidden.hashCode),
              card: hand[i],
              isActive: false,
            ),
          )
      );

      rowCount++;
    }
    if (rowCount != 0) {
      playerRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: playerCards,
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: playerRows,
    );
  }

  Widget _renderGameStarted(Started state, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Dealer",
          style: theme.textTheme.displayLarge,
        ),
        _getCardRows(state.dealer.hand, theme, true),
        Text(
          "Player",
          style: theme.textTheme.displayLarge,
        ),
        _getCardRows(state.player.hand, theme, false),
      ],
    );
  }

  void showEndGameDialog(BuildContext context, String text) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext inner) {
        return AlertDialog(
          title: Text(text),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to po4esat\' kolodu?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Play'),
              onPressed: () {
                context.read<GameBloc>().add(InitGame());
                Navigator.of(inner).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
