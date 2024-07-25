A [bloc](https://pub.dev/packages/bloc) extension to test async operations
using [bloc_test](https://pub.dev/packages/bloc_test).

# The problem

[bloc_test](https://pub.dev/packages/bloc_test) provides a `wait` parameter to delay the execution
of the `expect` block to test
async operations.
When the async operation takes longer than the `wait` duration, the test fails as not all
states defined in `expected` have been emitted.

Thus the `wait` parameter has to be set to a static, estimated duration.
If the underlying async operation takes longer than this duration the test will fail.

# The solution

Use the `bloc_test_async` package to ditch the `wait` parameter and instead await the completion of
events.

```
  blocTest("ExampleBloc",
      build: () => ExampleBloc(),
      act: (bloc) async {
        await bloc.addToComplete(ExampleEvent());
      },
      expect: () => [ExampleLoadingState(), ExampleSuccessState()]);
```

The extension method `addToComplete` adds an event to a bloc and returns a `Future` to
await the completion of the event in the bloc.
The `wait` parameter is left out as it is ensured that the events added in `act` have been
completed.

#Migrating your tests

## Bloc

Your bloc implementation has to be adjusted to complete events to use `addToComplete` in your test.
Simply adjust your calls from `on` to `completeOn`:

```
class MyBloc extends Bloc<Event, State> {
    MyBloc() : super(Initial()) {
        //previously on<Event>((event, emit)
       completeOn<Event>((event, emit) async {
            emit(Loading());
            // do stuff
            emit(Success());
        }
    }
}
```

When `completeOn` is run outside of a test context, the code to signal event completion is skipped and it
behaves just like `on`.

## blocTest

In your `blocTest` remove the `wait` parameter and use `await addToComplete()` instead of `add()` in
the `act` block.

```
  blocTest("MyBloc",
      build: () => MyBloc(),
      act: (bloc) async {
        //previously bloc.add(Event());
        await bloc.addToComplete(Event());
      },
      expect: () => [Loading(), Success()]);
```

When `addToComplete` is used outside of a test context, an exception is thrown.

That`s it. Enjoy.




