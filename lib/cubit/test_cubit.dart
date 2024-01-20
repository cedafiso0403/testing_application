import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'test_cubit.freezed.dart';
part 'test_cubit.g.dart';
part 'test_state.dart';

class TestCubit extends HydratedCubit<TestState> {
  TestCubit()
      : super(
          const TestState.initial(
            running: false,
            count: 0,
            startTime: null,
            currentTime: null,
          ),
        );

  void test() async {
    while (state.running) {
      await Future.delayed(
        const Duration(
          seconds: 5,
        ),
        () => emit(
          state.copyWith(
            count: state.count + 1,
          ),
        ),
      );
      print('Test');
    }
  }

  void setStartTime(DateTime dateTime) {
    emit(
      state.copyWith(
        startTime: dateTime,
      ),
    );
  }

  void setCurrentTime(DateTime dateTime) {
    emit(
      state.copyWith(
        currentTime: dateTime,
      ),
    );
  }

  void start() {
    emit(
      state.copyWith(
        running: true,
      ),
    );
    test();
  }

  void stop() {
    emit(
      state.copyWith(
        running: false,
      ),
    );
  }

  @override
  TestState? fromJson(Map<String, dynamic> json) => TestState.fromJson(json);

  @override
  Map<String, dynamic> toJson(TestState state) => state.toJson();
}
