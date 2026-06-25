import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/shared/cubit/settings_state.dart';
import 'package:honset_app/shared/data/firestore_settings_data_source.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._dataSource) : super(const SettingsState());

  final FirestoreSettingsDataSource _dataSource;

  Future<void> loadInstaPayLink() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final link = await _dataSource.getInstaPayLink();
      debugPrint('[SETTINGS] instaPayLink loaded: $link');
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        instaPayLink: link,
      ));
    } on Object catch (error) {
      debugPrint('[SETTINGS] Failed to load instaPayLink: $error');
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}
