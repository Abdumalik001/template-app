import 'package:cactus_hr/core/dependencies_injection.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_cubit.freezed.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AppStorageContract _storage;

  SettingsCubit([AppStorageContract? storage])
    : _storage = storage ?? sl<AppStorageContract>(),
      super(const SettingsStateLoading());

  void loadSettings() => emit(SettingsStateSuccess(_settings));

  DataHelper get settings => _settings;

  void updateTheme(ActiveTheme activeTheme) {
    _storage.setPref(PrefKey.theme, activeTheme.name);
    emit(SettingsStateSuccess(_settings));
  }

  void updateLanguage(String type) {
    /// Update locale code
    _storage.setPref(PrefKey.locale, type);
    emit(SettingsStateSuccess(_settings));
  }

  ActiveTheme getActiveTheme() => ActiveTheme.values.singleWhere(
    (element) =>
        element.name == (_storage.getPref<String>(PrefKey.theme) ?? ActiveTheme.system.name),
  );

  DataHelper get _settings => DataHelper(
    activeTheme: getActiveTheme(),
    type: _storage.getPref<String>(PrefKey.locale) ?? 'en',
  );
}

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.loading() = SettingsStateLoading;

  const factory SettingsState.success(DataHelper data) = SettingsStateSuccess;

  const factory SettingsState.failure(String message) = SettingsStateFailure;
}
