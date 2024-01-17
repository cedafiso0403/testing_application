import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_state.dart';
part 'test_cubit.freezed.dart';

class TestCubit extends Cubit<TestState> {
  TestCubit()
      : super(
          const TestState.initial(
            running: false,
            count: 0,
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
}
