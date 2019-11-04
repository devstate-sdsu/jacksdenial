import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jackshub/src/bloc/saved_events_event.dart';
import 'package:jackshub/src/bloc/saved_events_state.dart';
import 'package:jackshub/src/repos/saved_events_repository.dart';

class SavedEventsBloc extends Bloc<SavedEventsEvent, SavedEventsState> {
  final SavedEventsRepo savedEventsRepo;

  SavedEventsBloc(this.savedEventsRepo);

  @override
  SavedEventsState get initialState => SavedEventsInitial();

  @override
  Stream<SavedEventsState> mapEventToState(
    SavedEventsEvent event,
  ) async* {
    yield SavedEventsLoading();
    if (event is GetSavedEvents) {
      try {
        final savedEvents = await savedEventsRepo.fetchSavedEvents();
        yield SavedEventsLoaded(savedEvents);
      } on Error {
        yield SavedEventsError("No events sorry sis");
      }
    }
  }
}
