import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/hotel.dart';

class ApiService {
  static const String baseUrl =
      'https://api.rerumapp.uk/api/v1';

  // IMPORTANT:
  // Do NOT put the Swagger URL here.
  //
  // Swagger:
  // https://api.rerumapp.uk/api/v1/swagger.json
  //
  // Actual API:
  // https://api.rerumapp.uk/api/v1

  String? _apiToken;

  final http.Client _client = http.Client();

  // ----------------------------------------------------------
  // SET TOKEN
  // ----------------------------------------------------------

  void setToken(String token) {
    _apiToken = token;
  }

  // ----------------------------------------------------------
  // AUTHENTICATE
  // ----------------------------------------------------------

  Future<String> authenticate({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth');

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    print('AUTH STATUS: ${response.statusCode}');
    print('AUTH RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Authentication failed: '
            '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final token = data['apiToken'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('API token not returned by ReRum');
    }

    _apiToken = token.toString();

    return _apiToken!;
  }

  // ----------------------------------------------------------
  // COMMON HEADERS
  // ----------------------------------------------------------

  Map<String, String> get _headers {
    if (_apiToken == null || _apiToken!.isEmpty) {
      throw Exception(
        'ReRum API token is missing. Authenticate first.',
      );
    }

    return {
      'Accept': 'application/json',
      'Authorization': _apiToken!,
    };
  }

  // ----------------------------------------------------------
  // GET HOTELS / PROPERTIES
  // ----------------------------------------------------------

  Future<List<Hotel>> fetchHotels({
    int page = 1,
    int pageSize = 50,
  }) async {
    final url = Uri.parse(
      '$baseUrl/properties'
          '?page=$page'
          '&pageSize=$pageSize',
    );

    print('GET: $url');

    final response = await _client.get(
      url,
      headers: _headers,
    );

    print('PROPERTY STATUS: ${response.statusCode}');
    print('PROPERTY RESPONSE: ${response.body}');

    if (response.statusCode == 403) {
      throw Exception(
        '403: ReRum API token is invalid or expired.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch properties: '
            '${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid ReRum response');
    }

    final results = decoded['results'];

    if (results is! List) {
      return [];
    }

    return results
        .whereType<Map>()
        .map(
          (item) => Hotel.fromReRumJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // ----------------------------------------------------------
  // GET HOTEL DETAILS
  // ----------------------------------------------------------

  Future<Hotel> getHotelDetails(String id) async {
    final url = Uri.parse(
      '$baseUrl/properties/$id',
    );

    print('GET DETAILS: $url');

    final response = await _client.get(
      url,
      headers: _headers,
    );

    print('DETAIL STATUS: ${response.statusCode}');
    print('DETAIL RESPONSE: ${response.body}');

    if (response.statusCode == 403) {
      throw Exception(
        '403: ReRum API token is invalid or expired.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Hotel not found');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch hotel details: '
            '${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    return Hotel.fromReRumJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  void dispose() {
    _client.close();
  }
}