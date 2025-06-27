import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FlutterSecureStorage storage;

  ThemeBloc({required this.storage}) : super(ThemeState.initial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final themeMode = await storage.read(key: 'theme_mode');
    emit(state.copyWith(
      isDarkMode: themeMode == 'dark',
    ));
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ThemeState> emit) async {
    final newIsDarkMode = !state.isDarkMode;
    await storage.write(
      key: 'theme_mode',
      value: newIsDarkMode ? 'dark' : 'light',
    );
    emit(state.copyWith(isDarkMode: newIsDarkMode));
  }
}
