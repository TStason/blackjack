import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template brightness_cubit}
/// A simple [Cubit] that manages the [ThemeData] as its state.
/// {@endtemplate}
class ThemeCubit extends Cubit<ThemeData> {
  /// {@macro brightness_cubit}
  ThemeCubit() : super(_darkTheme);

  static final _lightTheme = ThemeData.light()
      .copyWith(scaffoldBackgroundColor: const Color.fromARGB(255, 211, 211, 211));

  static final _darkTheme = ThemeData.dark();

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
  }
}

extension BlackJackTheme on ThemeData {
  String get suitAsset {
    return brightness == Brightness.dark ? "images/cards/suit_red.png" : "images/cards/suit_blue.png";
  }
}