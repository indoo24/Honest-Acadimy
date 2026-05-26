import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';

class CoachesCubit extends Cubit<CoachesState> {
  CoachesCubit(this._repository) : super(const CoachesState.initial());

  final CoachRepository _repository;
  StreamSubscription<List<CoachProfile>>? _subscription;

  Future<void> loadCoaches() async {
    emit(state.copyWith(status: CoachesStatus.loading));
    try {
      final coaches = await _repository.getCoaches();
      emit(
        state.copyWith(status: CoachesStatus.loaded, coaches: coaches),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: CoachesStatus.failure, message: error.toString()),
      );
    }
  }

  void watchCoaches() {
    _subscription?.cancel();
    emit(state.copyWith(status: CoachesStatus.loading));
    _subscription = _repository.watchCoaches().listen(
      (coaches) {
        emit(state.copyWith(status: CoachesStatus.loaded, coaches: coaches));
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: CoachesStatus.failure,
            message: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum CoachesStatus { initial, loading, loaded, failure }

class CoachesState {
  const CoachesState({
    required this.status,
    this.coaches = const [],
    this.message,
  });

  const CoachesState.initial() : this(status: CoachesStatus.initial);

  final CoachesStatus status;
  final List<CoachProfile> coaches;
  final String? message;

  CoachesState copyWith({
    CoachesStatus? status,
    List<CoachProfile>? coaches,
    String? message,
  }) {
    return CoachesState(
      status: status ?? this.status,
      coaches: coaches ?? this.coaches,
      message: message,
    );
  }
}
