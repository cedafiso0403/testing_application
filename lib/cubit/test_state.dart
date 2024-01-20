part of 'test_cubit.dart';

@freezed
class TestState with _$TestState {
  const factory TestState.initial({
    required bool running,
    required int count,
    required DateTime? startTime,
    required DateTime? currentTime,
  }) = _Initial;

  factory TestState.fromJson(Map<String, dynamic> json) =>
      _$TestStateFromJson(json);
}
