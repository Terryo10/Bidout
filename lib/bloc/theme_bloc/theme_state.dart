part of 'theme_bloc.dart';

class ThemeState {
  final bool isDarkMode;

  ThemeState({required this.isDarkMode});

  factory ThemeState.initial() => ThemeState(isDarkMode: false);

  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
