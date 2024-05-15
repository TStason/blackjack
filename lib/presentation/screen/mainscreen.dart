import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';
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
                Future.delayed(const Duration(seconds: 2),() => {
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
            child: Text("Take", style: theme.textTheme.displayLarge,),
            // child: const Icon(Icons.add),
            onPressed: () {
              context.read<GameBloc>().add(PlayerHitCard());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: Text("Hold", style: theme.textTheme.displayLarge,),
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
    return Container(
      color: theme.scaffoldBackgroundColor,
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
          SvgPicture.asset(
            "images/cards/clubs_2.svg",
            semanticsLabel: "My SVG Image",
            height: 150,
            width: 105,
          )
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

  Widget _getPlayerRows(Started state, ThemeData theme, bool isDealer) {
    final List<PlayingCard> hand;
    if (isDealer) {
      hand = state.dealer.hand;
    } else {
      hand = state.player.hand;
    }
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
      if (i == 1 && isDealer && state is PlayerDraw) {
        playerCards.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Image.asset(
                theme.suitAsset,
                height: 150,
                width: 105,
              ),
            )
        );
      } else {
        playerCards.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _getCardOf(hand[i]),
            )
        );
      }

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
    List<Widget> dealerCards = [];
    // for (var element in state.dealer.hand) {
    //   // && state is PlayerDraw
    //   if (state.dealer.hand.first == element && state is PlayerDraw) {
    //     dealerCards.add(
    //         Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 5),
    //           child: Image.asset(
    //             "images/cards/suit_red.png",
    //             height: 150,
    //             width: 105,
    //           ),
    //         )
    //     );
    //     continue;
    //   }
    //   dealerCards.add(
    //       Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 5),
    //         child: _getCardOf(element),
    //       )
    //   );
    // }
    // List<Widget> playerCards = [];
    // for (var element in state.player.hand) {
    //   playerCards.add(
    //       Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 5),
    //         child: _getCardOf(element),
    //       )
    //   );
    // }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Dealer",
          style: theme.textTheme.displayLarge,
        ),
        _getPlayerRows(state, theme, true),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: dealerCards,
        // ),
        Text(
          "Player",
          style: theme.textTheme.displayLarge,
        ),
        _getPlayerRows(state, theme, false),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: playerCards,
        // ),
      ],
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
