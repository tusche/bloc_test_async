import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_test_async/bloc_test_async.dart';
import 'package:equatable/equatable.dart';

class RandomDelayEvent {}

sealed class State extends Equatable {
  @override
  List<Object?> get props => [];
}

class Initial extends State {}

class Loading extends State {}

class Success extends State {}

class RandomDelayBloc extends Bloc<RandomDelayEvent, State> {
  RandomDelayBloc() : super(Initial()) {
    completeOn<RandomDelayEvent>((event, emit) async {
      emit(Loading());

      Duration delay = Duration(milliseconds: Random().nextInt(2000));
      await Future.delayed(delay);

      emit(Success());
    });
  }
}

void main() {
  blocTest("RandomDelayBloc",
      build: () => RandomDelayBloc(),
      act: (bloc) async {
        await bloc.addToComplete(RandomDelayEvent(),
            timeout: const Duration(milliseconds: 2500));
      },
      expect: () => [Loading(), Success()]);
}
