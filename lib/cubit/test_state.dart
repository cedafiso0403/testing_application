part of 'test_cubit.dart';

@freezed
class TestState with _$TestState {
  const factory TestState.initial({
    required bool running,
    required int count,
  }) = _Initial;
}
