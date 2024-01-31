part of 'travel_bloc.dart';

class TravelState extends Equatable {
  const TravelState();

  @override
  List<Object?> get props => [];
}

class TravelInitialState extends TravelState {}

class TravelLoadingState extends TravelState {}

class TravelLoadedState extends TravelState {
  final LocationModel locations;
  const TravelLoadedState({required this.locations});
}

class TravelErrorState extends TravelState {
  final String? message;
  const TravelErrorState({required this.message});
}
