import '../models/location_model.dart';
import '../providers/travel_provider.dart';

class TravelRepository {
  final travelProvider = TravelProvider();

  Future<LocationModel> fetchLocationList() {
    return travelProvider.fetchLocationsList();
  }
}

class NetworkError extends Error {}
