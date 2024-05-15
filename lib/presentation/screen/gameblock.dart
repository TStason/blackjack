import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stack/stack.dart';

abstract class CounterEvent {}

class InitGame extends CounterEvent {}
class PlayerHitCard extends CounterEvent {}
class PlayerHold extends CounterEvent {}
class DealerHitCard extends CounterEvent {}

abstract class GameState {}
class Initial extends GameState {}
class Started extends GameState {
  Deck deck;
  Player player;
  Player dealer;

  Started({required this.deck, required this.player, required this.dealer});
}
class PlayerDraw extends Started {
  PlayerDraw({required super.deck, required super.player, required super.dealer});
}
class DealerDraw extends Started {
  DealerDraw({required super.deck, required super.player, required super.dealer});
}
class DealerWin extends Started {
  DealerWin({required super.deck, required super.player, required super.dealer});
}
class PlayerWin extends Started {
  PlayerWin({required super.deck, required super.player, required super.dealer});
}

class GameBloc extends Bloc<CounterEvent, GameState> {
  GameBloc() : super(Initial()) {
    on<InitGame>((event, emit) => emit(_initializeGame(event, state)));
    on<PlayerHitCard>((event, emit) => emit(_playerHitCard(state)));
    on<PlayerHold>((event, emit) => emit(_playerHold(state)));
    on<DealerHitCard>((event, emit) => emit(_dealerHitCard(state)));
  }

  GameState _initializeGame(InitGame event, GameState currentState) {
    switch (currentState) {
      case DealerWin _:
      case PlayerWin _:
      case Initial _:
        Deck deck = Deck();
        final dealerHiddenCard = deck.hit();
        dealerHiddenCard.isHidden = true;
        Player dealer = Player(hand: [dealerHiddenCard, deck.hit()]);
        Player player = Player(hand: [deck.hit(), deck.hit()]);
        // bool dealerBlackJack = _isBlackJack(dealer.hand);
        // if (dealerBlackJack) {
        //   print("DealerWin");
        // }
        bool playerBlackJack = _isBlackJack(player.hand);
        if (playerBlackJack) {
          // TODO: If dealer have ten point, then show dialog, else Player win
          return PlayerWin(
              deck: deck,
              dealer: dealer,
              player: player
          );
        }
        return PlayerDraw(
            deck: deck,
            dealer: dealer,
            player: player
        );
    }
    return currentState;
  }

  GameState _playerHitCard(GameState currentState) {
    switch (currentState) {
      case PlayerDraw s1:
        s1.player.hand.add(s1.deck.hit());
        if (_isOverflow(s1.player.hand)) {
          return DealerWin(
              deck: s1.deck,
              dealer: s1.dealer,
              player: s1.player
          );
        } else if (_isBlackJack(s1.player.hand)) {
          // TODO: stop player hit and start dealer draw
          return DealerDraw(
              deck: s1.deck,
              player: s1.player,
              dealer: s1.dealer
          );
        }
        return PlayerDraw(
          deck: s1.deck,
          player: s1.player,
          dealer: s1.dealer
        );
    }
    return currentState;
  }

  GameState _playerHold(GameState currentState) {
    switch (currentState) {
      case PlayerDraw s1: {
        // TODO: test
        s1.dealer.hand.first.isHidden = false;
        s1.dealer.hand.first.animateHidden = true;
        if (_isOverflow(s1.dealer.hand)) {
          return PlayerWin(
              deck: s1.deck,
              dealer: s1.dealer,
              player: s1.player
          );
        } else if (_isBlackJack(s1.dealer.hand)) {
          return DealerWin(
              deck: s1.deck,
              dealer: s1.dealer,
              player: s1.player
          );
        }
        return DealerDraw(
            deck: s1.deck,
            player: s1.player,
            dealer: s1.dealer
        );
      }
    }
    return currentState;
  }

  GameState _dealerHitCard(GameState currentState) {
    switch (currentState) {
      case DealerDraw s1:
        s1.dealer.hand.first.animateHidden = false;
        // TODO: apply dealer strategy
        if (_canDealerHold(s1.dealer.hand)) {
          int playerValue = _getValue(s1.player.hand);
          int dealerValue = _getValue(s1.dealer.hand);
          if (playerValue > dealerValue) {
            return PlayerWin(
                deck: s1.deck,
                dealer: s1.dealer,
                player: s1.player
            );
          } else {
            return DealerWin(
                deck: s1.deck,
                dealer: s1.dealer,
                player: s1.player
            );
          }
        }

        s1.dealer.hand.add(s1.deck.hit());
        if (_isOverflow(s1.dealer.hand)) {
          return PlayerWin(
              deck: s1.deck,
              dealer: s1.dealer,
              player: s1.player
          );
        } else if (_isBlackJack(s1.dealer.hand)) {
          return DealerWin(
              deck: s1.deck,
              dealer: s1.dealer,
              player: s1.player
          );
        }
        return DealerDraw(
            deck: s1.deck,
            player: s1.player,
            dealer: s1.dealer
        );
    }
    return currentState;
  }

  bool _canDealerHold(List<PlayingCard> dealerHand) {
    int value = _getValue(dealerHand);
    return value >= 17;
  }

  bool _isBlackJack(List<PlayingCard> cards) {
    int value = _getValue(cards);
    return value == 21;
  }

  bool _isOverflow(List<PlayingCard> cards) {
    int value = _getValue(cards);
    return value > 21;
  }

  int _getValue(List<PlayingCard> cards) {
    int value = 0;
    for (var element in cards) {
      // Check if ACE
      value += element.value;
    }
    return value;
  }
}

class Player {
  List<PlayingCard> hand;
  Player({required this.hand});
}

class Deck {
  Stack<PlayingCard> cards = Stack();
  Deck() {
    List<PlayingCard> shuffled = List<PlayingCard>.empty(growable: true);
    shuffled.addAll(
        _generateCards(CardSuit.CLUBS)
    );
    shuffled.addAll(
        _generateCards(CardSuit.DIAMONDS)
    );
    shuffled.addAll(
        _generateCards(CardSuit.HEARTS)
    );
    shuffled.addAll(
        _generateCards(CardSuit.SPADES)
    );

    shuffled.shuffle();
    for (var element in shuffled) {
      cards.push(element);
    }
  }

  // IllegalOperationException
  PlayingCard hit() {
    return cards.pop();
  }

  List<PlayingCard> _generateCards(CardSuit suit) {
    List<PlayingCard> cards = List<PlayingCard>.generate(13, (index) {
      PlayingCard card;
      if (index < 9) {
        card = NumeralsCard(
            value: index+2,
            suite: suit
        );
      } else if (index == 9) {
        card = CourtCard(
            type: Court.JACK,
            value: 10,
            suite: suit
        );
      } else if (index == 10) {
        card = CourtCard(
            type: Court.QUEEN,
            value: 10,
            suite: suit
        );
      } else if (index == 11) {
        card = CourtCard(
            type: Court.KING,
            value: 10,
            suite: suit
        );
      } else {
        card = AceCard(
            value: 11,
            suite: suit
        );
      }
      return card;
    });
    return cards;
  }
}

class PlayingCard {
  int value;
  CardSuit suite;
  bool isHidden = false;
  bool animateHidden = false;

  PlayingCard({required this.value, required this.suite});
}

class NumeralsCard extends PlayingCard {
  NumeralsCard({required super.value, required super.suite});
}

class CourtCard extends PlayingCard {
  Court type;
  CourtCard({required this.type, required super.value, required super.suite});
}

class AceCard extends PlayingCard {
  int minVal = 1;
  AceCard({required super.value, required super.suite});
}

enum Court {
  JACK("jack"),
  QUEEN("queen"),
  KING("king");

  const Court(this.name);
  final String name;
}

enum CardSuit {
  HEARTS("hearts"),
  DIAMONDS("diamonds"),
  CLUBS("clubs"),
  SPADES("spades");

  const CardSuit(this.name);
  final String name;
}

extension CardIcon on PlayingCard {
  String get asset {
    const assetPath = "images/cards";
    if (this is NumeralsCard) {
      return "$assetPath/${suite.name}_$value.svg";
    } else if (this is CourtCard) {
      return "$assetPath/${suite.name}_${(this as CourtCard).type.name}.png";
    } else if (this is AceCard) {
      return "$assetPath/${suite.name}_ace.svg";
    }
    throw "Unsupported Card type $this";
  }
}