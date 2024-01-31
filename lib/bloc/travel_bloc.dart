import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/location_model.dart';
import '../data/repositories/travel_repository.dart';
part 'travel_event.dart';
part 'travel_state.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  TravelBloc() : super(TravelInitialState()) {
    final TravelRepository travelRepository = TravelRepository();

    on<GetLocationList>((event, emit) async {
      try {
        emit(TravelLoadingState());
        LocationModel locationModel =
            await travelRepository.fetchLocationList();
        emit(TravelLoadedState(locations: locationModel));
        if (locationModel.error != null) {
          emit(TravelErrorState(message: locationModel.error));
        }
      } on NetworkError {
        emit(const TravelErrorState(
            message: 'Failed to fetch data. is your device online?'));
      }
    });
  }
}
