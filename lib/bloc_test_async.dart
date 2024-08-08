import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';

class EventCompleters {
  Map<dynamic, Completer> map = {};
}

extension Complete<Event, State> on Bloc<Event, State> {
  void completeOn<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    on((event, emit) async {
      await handler(event, emit);
      EventCompleters eventCompleters = _getEventCompleters();
      Completer? completer = eventCompleters.map[event];
      if (completer != null) {
        completer.complete();
        eventCompleters.map.remove(event);
      }
    }, transformer: transformer);
  }

  Future<void> addToComplete(Event event,
      {Duration timeout = const Duration(seconds: 30)}) {
    EventCompleters eventCompleters = _getEventCompleters();
    Map<dynamic, Completer> map = eventCompleters.map;
    if (map.containsKey(event)) {
      throw "event was already added and is not yet completed";
    }
    Completer completer = Completer();
    map[event] = completer;
    add(event);
    return completer.future.timeout(timeout);
  }

  EventCompleters _getEventCompleters() {
    var getIt = GetIt.instance;
    EventCompleters eventCompleters;
    if (getIt.isRegistered<EventCompleters>()) {
      eventCompleters = getIt.get<EventCompleters>();
    } else {
      eventCompleters = EventCompleters();
      getIt.registerSingleton(eventCompleters);
    }
    return eventCompleters;
  }
}
