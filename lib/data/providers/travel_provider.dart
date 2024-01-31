import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class TravelProvider {
  static const String apiUrl = 'http://142.93.106.105/interview/getRoutes.php';

  Future<LocationModel> fetchLocationsList() async {
    try {
      // Check if data is stored locally and not expired
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String storedData = prefs.getString('locations') ?? '';
      final int lastFetchTime = prefs.getInt('lastFetchTime') ?? 0;
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (storedData.isNotEmpty && currentTime - lastFetchTime < 60000) {
        // Use locally stored data if available and not expired
        final dynamic decodedData = jsonDecode(storedData);
        return LocationModel.fromJson(decodedData);
      } else {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Basic dml0ZWNkZXY6TTQ4OnRed1VCZSV5'},
        );
        if (response.statusCode == 200) {
          final dynamic decodedData = jsonDecode(response.body);
          // Store data locally
          prefs.setString('locations', jsonEncode(decodedData));
          prefs.setInt('lastFetchTime', currentTime);
          return LocationModel.fromJson(decodedData);
        } else {
          throw Exception('Failed to load locations');
        }
      }
    } catch (error, stacktrace) {
      if (kDebugMode) {
        print('Exception occured: $error stackTrace: $stacktrace');
      }
      return LocationModel.withError('Data not found / Connection issue');
    }
  }
}
