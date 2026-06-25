import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.instaPayLink,
    this.errorMessage,
  });

  final SettingsStatus status;
  final String? instaPayLink;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    String? instaPayLink,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      instaPayLink: instaPayLink ?? this.instaPayLink,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, instaPayLink, errorMessage];
}
